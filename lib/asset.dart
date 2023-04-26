import 'dart:async';
import 'dart:ui' as ui;

import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class Asset extends ImageProvider<Asset> {
  bool hasLocal = false;
  bool hasRemote = false;
  AssetEntity? local;
  RemoteImage? remote;
  Completer<Uint8List>? _thumbnailDataCompleter;
  Uint8List? _thumbnailData;
  Completer<Uint8List>? _dataAsyncCompleter;
  Uint8List? _data;

  String? make;
  String? model;
  int? imageWidth;
  int? imageHeight;
  double imageSize = 0;
  String? date;
  String? iSO;
  String? exposureTime;
  String? fNumber;
  String? focalLength;

  Asset({this.local, this.remote}) {
    if (local != null) {
      hasLocal = true;
    }
    if (remote != null) {
      hasRemote = true;
    }
  }

  bool isLocal() {
    return hasLocal;
  }

  String? name() {
    if (hasLocal) {
      return local!.title;
    }
    if (hasRemote) {
      return basename(remote!.path);
    }
    return "";
  }

  String? mimeType() {
    if (name() == null) {
      return null;
    }
    final RegExp regex = RegExp(r'\.([a-zA-Z0-9]+)$');
    final Match? match = regex.firstMatch(name()!);

    if (match != null && match.groupCount > 0) {
      final String extension = match.group(1)?.toLowerCase() ?? '';

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        case 'gif':
          return 'image/gif';
        case 'bmp':
          return 'image/bmp';
        case 'webp':
          return 'image/webp';
        case 'heic':
          return 'image/heic';
        case 'heif':
          return 'image/heif';
        case 'dng':
          return 'image/x-adobe-dng';
        case 'tif':
        case 'tiff':
          return 'image/tiff';
        case 'cr2':
          return 'image/x-canon-cr2';
        case 'nef':
          return 'image/x-nikon-nef';
        case 'arw':
          return 'image/x-sony-arw';
        case 'rw2':
          return 'image/x-panasonic-rw2';
        case 'orf':
          return 'image/x-olympus-orf';
        case 'pef':
          return 'image/x-pentax-pef';
        case 'raf':
          return 'image/x-fuji-raf';
        case 'x3f':
          return 'image/x-sigma-x3f';
        case 'srw':
          return 'image/x-samsung-srw';
        default:
          return null;
      }
    } else {
      return null;
    }
  }

  DateTime dateCreated() {
    if (hasLocal) {
      return local!.modifiedDateTime;
    }
    if (hasRemote) {
      RegExp datePattern = RegExp(r'(\d{4})/(\d{2})/(\d{2})');
      Match? match = datePattern.firstMatch(remote!.path);

      if (match != null) {
        if (match.groupCount != 3) {
          return DateTime.now();
        }
        int year = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int day = int.parse(match.group(3)!);

        return DateTime(year, month, day);
      } else {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Uint8List thumbnailData() {
  //   if (_thumbnailData != null) {
  //     return _thumbnailData!;
  //   }
  //   return Uint8List(0);
  // }

  ImageProvider thumbnailProvider() {
    if (_thumbnailData != null && _thumbnailData!.isNotEmpty) {
      return MemoryImage(_thumbnailData!);
    }
    return Image.asset("assets/images/broken.png").image;
  }

  Future<Uint8List> thumbnailDataAsync() async {
    if (_thumbnailData != null) {
      return _thumbnailData!;
    }
    if (_thumbnailDataCompleter != null) {
      return _thumbnailDataCompleter!.future;
    }
    _thumbnailDataCompleter = Completer<Uint8List>();
    Uint8List? data;
    if (hasLocal) {
      data = await local!.thumbnailData;
    }
    if (hasRemote) {
      data = await remote!.thumbnail();
    }
    if (data == null || data.isEmpty) {
      final brokenData = await rootBundle.load("assets/images/broken.png");
      _thumbnailDataCompleter!.complete(brokenData.buffer.asUint8List());
      return brokenData.buffer.asUint8List();
    } else {
      _thumbnailDataCompleter!.complete(data);
      _thumbnailData = data;
      return data;
    }
  }

  Future<Uint8List> imageDataAsync() async {
    if (_data != null) {
      return _data!;
    }
    if (_dataAsyncCompleter != null) {
      return _dataAsyncCompleter!.future;
    }
    _dataAsyncCompleter = Completer<Uint8List>();
    Uint8List? data;
    try {
      if (hasLocal) {
        data = await local!.originBytes;
      }
      if (hasRemote) {
        data = await remote!.imageData();
      }
    } catch (e) {
      print(e);
    }
    if (data == null || data.isEmpty) {
      final brokenData = await rootBundle.load("assets/images/broken.png");
      _dataAsyncCompleter!.complete(brokenData.buffer.asUint8List());
      return brokenData.buffer.asUint8List();
    } else {
      _dataAsyncCompleter!.complete(data);
      _data = data;
      return data;
    }
  }

  String path() {
    if (hasLocal) {
      if (local!.relativePath == null) {
        return "unknown";
      }
      return "${local!.relativePath!}${local!.title}";
    }
    if (hasRemote) {
      return remote!.path;
    }
    return "";
  }

  Future<void> delete() async {
    if (hasLocal) {
      await PhotoManager.editor.deleteWithIds([local!.id]);
    }
    if (hasRemote) {
      final rsp = await remote!.cli.delete(DeleteRequest(
        paths: [remote!.path],
      ));
      if (!rsp.success) {
        throw Exception("delete failed: ${rsp.message}");
      }
    }
  }

  AssetEntity? getLocal() {
    return local;
  }

  bool _isInfoReaded = false;
  bool _isSizeInfoReadedFinished = false;
  bool _isExifInfoReadedFinished = false;

  bool isInfoReady() {
    return _isSizeInfoReadedFinished && _isExifInfoReadedFinished;
  }

  Future<void> readInfoFromData() async {
    if (_isInfoReaded) {
      return;
    }
    _isInfoReaded = true;
    final data = await imageDataAsync();
    if (isLocal()) {
      imageWidth = getLocal()!.width;
      imageHeight = getLocal()!.height;
      imageSize = data.length / 1024 / 1024;
      _isSizeInfoReadedFinished = true;
    } else {
      compute(img.decodeImage, data).then((image) {
        if (image != null) {
          imageWidth = image.width;
          imageHeight = image.height;
          imageSize = data.length / 1024 / 1024;
        }
        _isSizeInfoReadedFinished = true;
      });
    }
    compute(readExifFromBytes, data).then((exifData) {
      if (exifData.isEmpty) {
        print("No Exif data found");
      } else {
        for (String key in exifData.keys) {
          // print("$key: ${exifData[key]!.printable}");
          switch (key) {
            case 'Image Make':
              make = exifData[key]!.toString();
              break;
            case 'Image Model':
              model = exifData[key]!.toString();
              break;
            case 'Image DateTime':
              final v = exifData[key]!.toString();
              if (v != "") {
                try {
                  DateTime dateTime = DateTime.parse(
                      v.replaceAll(':', '').replaceAll(' ', 'T'));
                  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
                  date = dateFormat.format(dateTime);
                } catch (e) {
                  print(e);
                }
              }
              break;
            case 'EXIF ISOSpeedRatings':
              iSO = exifData[key]!.toString();
              break;
            case 'EXIF ExposureTime':
              exposureTime = exifData[key]!.toString();
              break;
            case 'EXIF FNumber':
              try {
                final v = exifData[key]!.toString();
                List<String> parts = v.split('/');

                int numerator = int.parse(parts[0]);
                int denominator = int.parse(parts[1]);

                double value = numerator / denominator;
                fNumber = value.toStringAsFixed(1);
              } catch (e) {
                print(e);
              }
              break;
            case "EXIF FocalLength":
              try {
                final v = exifData[key]!.toString();
                List<String> parts = v.split('/');

                int numerator = int.parse(parts[0]);
                int denominator = int.parse(parts[1]);
                double value = numerator / denominator;
                focalLength = value.toStringAsFixed(2);
              } catch (e) {
                print(e);
              }
              break;
            default:
              break;
          }
        }
      }
      _isExifInfoReadedFinished = true;
    });
  }

  @override
  Future<Asset> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Asset>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(Asset key, DecoderBufferCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(Asset key, DecoderBufferCallback decode) async {
    Uint8List data = await imageDataAsync();
    if (data.isEmpty) {
      data = await thumbnailDataAsync();
    }
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    final ui.FrameInfo fi = await codec.getNextFrame();
    return ImageInfo(image: fi.image);
  }

  @override
  String toString() => 'Asset(local: $local, remote: $remote)';
}