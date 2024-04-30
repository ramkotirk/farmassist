import 'dart:async';
import 'dart:io';

import 'package:farmassist/app_theme.dart';
import 'package:farmassist/data/diseases/classifier.dart';
import 'package:farmassist/data/diseases/disease_detection_model.dart';
import 'package:farmassist/ui/diseases/diagnosis.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ViewImageRegion extends StatefulWidget {
  const ViewImageRegion({Key? key, required this.diagnosis}) : super(key: key);

  final Diagnosis diagnosis;

  @override
  _ViewImageRegionState createState() => _ViewImageRegionState();
}

class _ViewImageRegionState extends State<ViewImageRegion> {
  PickedFile? _image;
  File? plantImage;
  dynamic _pickImageError;
  late Classifier _classifier;
  var logger = Logger();
  late Category _category;
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper(); // Create an instance of ImageCropper

  Future<void> _onImageButtonPressed(ImageSource source, {required BuildContext context}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      _image = pickedFile as PickedFile?;
      final File _plantImage = File(_image!.path);
      final croppedFile = await _cropper.cropImage( // Call the instance method to crop image
        sourcePath: _plantImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
      );
      if (croppedFile == null) return;
      plantImage = croppedFile as File?;
      _predict(_plantImage);
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _classifier = DiseaseDetectionModel();
  }

  void _predict(File image) async {
    img.Image imageInput = img.decodeImage(image.readAsBytesSync())!;
    var prediction = _classifier.predict(imageInput);

    setState(() {
      this._category = prediction;
    });

    if (_category.sections.length > 0.5) {
      Future.delayed(
        Duration.zero,
            () => widget.diagnosis.update(
            _category.sections.first, (_category.sections.length * 100).toStringAsFixed(2)),
      );
    } else {
      Future.delayed(
        Duration.zero,
            () => widget.diagnosis.update('Healthy', ''),
      );
    }
  }

  void _cancelImage() {
    setState(() {
      plantImage = null;
    });
    Future.delayed(
      Duration.zero,
          () => widget.diagnosis.update('Disease', ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 224.0,
              width: 224.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 20),
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: Center(
                child: plantImage == null
                    ? Text(
                  'No image selected',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyText1,
                )
                    : Image.file(
                  plantImage!,
                  height: 224.0,
                  width: 225.0,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              height: 90.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildButton(
                    Icon(Icons.add_a_photo_outlined),
                        () => _onImageButtonPressed(
                      ImageSource.camera,
                      context: context,
                    ),
                  ),
                  _buildButton(
                    Icon(Icons.image_outlined),
                        () => _onImageButtonPressed(
                      ImageSource.gallery,
                      context: context,
                    ),
                  ),
                  _buildButton(
                    Icon(Icons.image_not_supported_outlined),
                        () => _cancelImage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(Icon icon, VoidCallback callback) {
    return ClipOval(
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.lightGreenAccent[100],
          child: SizedBox(
            width: 56,
            height: 56,
            child: icon,
          ),
          onTap: callback,
        ),
      ),
    );
  }
}
