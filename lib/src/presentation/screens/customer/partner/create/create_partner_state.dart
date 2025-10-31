enum FormStatus { idle, loading, success, error }

enum PartnerType { client, contact }

class CreatePartnerState {
  final FormStatus status;
  final PartnerType partnerType;
  final int currentStep;
  final String? errorMessage;
  final Map<String, dynamic> formData;

  CreatePartnerState({
    this.status = FormStatus.idle,
    this.partnerType = PartnerType.client,
    this.currentStep = 0,
    this.errorMessage,
    this.formData = const {},
  });

  CreatePartnerState copyWith({
    FormStatus? status,
    PartnerType? partnerType,
    int? currentStep,
    String? errorMessage,
    Map<String, dynamic>? formData,
  }) {
    return CreatePartnerState(
      status: status ?? this.status,
      partnerType: partnerType ?? this.partnerType,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: errorMessage ?? this.errorMessage,
      formData: formData ?? this.formData,
    );
  }

  bool get isClient => partnerType == PartnerType.client;
  bool get isLoading => status == FormStatus.loading;
}
