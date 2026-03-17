import 'package:devalay_app/src/data/model/explore/filter/admin_filter_model.dart';
import 'package:devalay_app/src/data/model/kirti/service_model.dart';
import 'package:devalay_app/src/data/model/kirti/skill_response_model.dart'
    show SkillResponseModel;

import '../../../data/model/contribution/donateModel.dart';
import '../../../data/model/contribution/donatePaymentModel.dart';
import '../../../data/model/kirti/adds_on_model.dart';
import '../../../data/model/kirti/category_model.dart';
import '../../../data/model/kirti/experience_model.dart';
import '../../../data/model/kirti/expertise_model.dart';
import '../../../data/model/kirti/fetch_skill_model.dart' show FetchSkillModel, Pandit;
import '../../../data/model/kirti/language_model.dart';
import '../../../data/model/kirti/order_response_model.dart';
import '../../../data/model/kirti/service_detail_model.dart';

abstract class ServiceState {}

class ServiceInitialState extends ServiceState {}

class ServiceLoadedState extends ServiceState {
  final bool loadingState;
  List<ServiceModel>? serviceList;
  ServiceDetailModel? service;
  List<ServiceFilterModel>? serviceFilterModel;
  SkillResponseModel? skillResponseModel;
  FetchSkillModel? fetchSkillModel;
  OrderResponseModel? orderResponseModel;
  DonateModel? donateModel;
  DonatePaymentModel? donatePaymentModel;
  List<AddsOnModel>? addOnsList;
  List<LanguageModel>? languageList;
  List<CategoryModel>? categoryList;
  List<ExpertiseModel>? expertiseList;
  List<ExperienceModel>? experienceList;
  List<Pandit>? availablePandits;

  bool isLoading;
  String errorMessage;

  ServiceLoadedState({
    required this.loadingState,
    this.serviceList,
    this.service,
    this.serviceFilterModel,
    this.skillResponseModel,
    this.fetchSkillModel,
    this.orderResponseModel,
    this.donateModel,
    this.donatePaymentModel,
    this.addOnsList,
    this.languageList,
    this.categoryList,
    this.expertiseList,
    this.experienceList,
    this.availablePandits,
    required this.isLoading,
    this.errorMessage = '',
  });
}