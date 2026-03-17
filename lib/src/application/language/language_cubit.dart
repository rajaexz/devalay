import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en'));

  void changeLanguage(Locale locale, BuildContext context) {
    context.setLocale(locale); // EasyLocalization updates
    emit(locale);            
  }
}
