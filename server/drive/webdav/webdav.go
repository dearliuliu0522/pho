package webdav

import (
	"bytes"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"time"

	"github.com/studio-b12/gowebdav"
)

type Webdav struct {
	url      string
	username string
	password string
	rootPath string
	cli      *gowebdav.Client
}

func NewWebdavDrive(url, username, password string) *Webdav {
	d := &Webdav{
		url:      url,
		username: username,
		password: password,
		cli:      gowebdav.NewClient(url, username, password),
	}
	return d
}

func (d *Webdav) Cli() *gowebdav.Client {
	return d.cli
}

func (d *Webdav) IsRootPathSet() bool {
	return d.rootPath != ""
}

func (d *Webdav) SetRootPath(rootPath string) error {
	if rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	rootPath = filepath.ToSlash(rootPath)
	var err error
	if rootPath[0] != '/' {
		rootPath = "/" + rootPath
	}
	if rootPath[len(rootPath)-1] != '/' {
		rootPath = rootPath + "/"
	}
	info, err := d.cli.Stat(rootPath)
	if err != nil {
		if os.IsNotExist(err) {
			return fmt.Errorf("root path %s not exist", rootPath)
		}
		return err
	}
	if !info.IsDir() {
		return fmt.Errorf("root path %s is not a dir", rootPath)
	}
	d.rootPath = rootPath
	return nil
}

func (d *Webdav) IsExist(path string) (bool, error) {
	if d.rootPath == "" {
		return false, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	_, err := d.cli.Stat(fullPath)
	if err != nil {
		if os.IsNotExist(err) {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func (d *Webdav) Download(path string) (io.ReadCloser, int64, error) {
	if d.rootPath == "" {
		return nil, 0, fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	// reader, err := d.cli.ReadStream(fullPath)
	// if err != nil {
	// 	return nil, 0, err
	// }
	data, err := d.cli.Read(fullPath)
	if err != nil {
		return nil, 0, err
	}
	reader := io.NopCloser(bytes.NewReader(data))
	return reader, int64(len(data)), nil
}

func (d *Webdav) Delete(path string) error {
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.cli.Remove(fullPath)
	if err != nil {
		return err
	}
	return nil
}

func (d *Webdav) Upload(path string, reader io.ReadCloser, size int64, lastModified time.Time) error {
	if reader == nil {
		return fmt.Errorf("reader is nil")
	}
	defer reader.Close()
	if d.rootPath == "" {
		return fmt.Errorf("root path is empty")
	}
	fullPath := filepath.Join(d.rootPath, path)
	err := d.cli.MkdirAll(filepath.Dir(fullPath), 0755)
	if err != nil {
		return err
	}
	err = d.cli.WriteStream(fullPath, reader, 0666)
	if err != nil {
		return err
	}

	return nil
}

func (d *Webdav) Range(dir string, deal func(fs.FileInfo) bool) {
	if d.rootPath == "" {
		return
	}
	fullPath := filepath.Join(d.rootPath, dir)
	infos, err := d.cli.ReadDir(fullPath)
	if err != nil {
		return
	}
	sort.Sort(desc(infos))
	for _, info := range infos {
		if !deal(info) {
			break
		}
	}
}

type desc []fs.FileInfo

func (d desc) Len() int      { return len(d) }
func (d desc) Swap(i, j int) { d[i], d[j] = d[j], d[i] }
func (d desc) Less(i, j int) bool {
	return d[i].ModTime().After(d[j].ModTime())
}