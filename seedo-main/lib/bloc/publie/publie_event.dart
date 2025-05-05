// publication_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seddoapp/models/CategorieModel.dart';

import '../../models/PricingModel.dart';

abstract class PublicationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TabChanged extends PublicationEvent {
  final int tabIndex;

  TabChanged(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class StepChanged extends PublicationEvent {
  final int stepIndex;

  StepChanged(this.stepIndex);

  @override
  List<Object?> get props => [stepIndex];
}

class CategorySelected extends PublicationEvent {
  final String category;

  CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class SubcategorySelected extends PublicationEvent {
  final CategorieModel subcategory;

  SubcategorySelected(this.subcategory);

  @override
  List<Object?> get props => [subcategory];
}

class FormFieldUpdated extends PublicationEvent {
  final String field;
  final String value;

  FormFieldUpdated(this.field, this.value);

  @override
  List<Object?> get props => [field, value];
}

class ImagesAdded extends PublicationEvent {
  final List<String> images;

  ImagesAdded(this.images);

  @override
  List<Object?> get props => [images];
}

class ImageRemoved extends PublicationEvent {
  final int index;

  ImageRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class PublicationSubmitted extends PublicationEvent {
  final int authorId;
  final double latitude;
  final double longitude;
  final BuildContext context;

  PublicationSubmitted({
    required this.authorId,
    required this.latitude,
    required this.longitude,
    required this.context,
  });
}

class LoadInitialPricing extends PublicationEvent {}

class PricingSelected extends PublicationEvent {
  final PricingModel selectedPricing;

  PricingSelected(this.selectedPricing);

  @override
  List<Object?> get props => [selectedPricing];
}
class LoadAppParam extends PublicationEvent {}