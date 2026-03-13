// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyNumber _$EmergencyNumberFromJson(Map<String, dynamic> json) =>
    EmergencyNumber(
      title: json['title'] as String,
      description: json['description'] as String,
      phone: json['phone'] as String?,
      alternativePhone: json['alternativePhone'] as String?,
    );

Map<String, dynamic> _$EmergencyNumberToJson(EmergencyNumber instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'phone': instance.phone,
      'alternativePhone': instance.alternativePhone,
    };

AmbulanceServicesResponse _$AmbulanceServicesResponseFromJson(
  Map<String, dynamic> json,
) => AmbulanceServicesResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: AmbulanceServicesData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AmbulanceServicesResponseToJson(
  AmbulanceServicesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

AmbulanceServicesData _$AmbulanceServicesDataFromJson(
  Map<String, dynamic> json,
) => AmbulanceServicesData(
  emergencyNumbers:
      (json['emergencyNumbers'] as List<dynamic>)
          .map((e) => EmergencyNumber.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$AmbulanceServicesDataToJson(
  AmbulanceServicesData instance,
) => <String, dynamic>{
  'emergencyNumbers': instance.emergencyNumbers,
  'total': instance.total,
};

Faq _$FaqFromJson(Map<String, dynamic> json) => Faq(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$FaqToJson(Faq instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
  'category': instance.category,
};

FaqResponse _$FaqResponseFromJson(Map<String, dynamic> json) => FaqResponse(
  faqs:
      (json['faqs'] as List<dynamic>)
          .map((e) => Faq.fromJson(e as Map<String, dynamic>))
          .toList(),
  categories:
      (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$FaqResponseToJson(FaqResponse instance) =>
    <String, dynamic>{'faqs': instance.faqs, 'categories': instance.categories};

CreateTicketRequest _$CreateTicketRequestFromJson(Map<String, dynamic> json) =>
    CreateTicketRequest(
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$CreateTicketRequestToJson(
  CreateTicketRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
};

TicketData _$TicketDataFromJson(Map<String, dynamic> json) => TicketData(
  ticketId: json['ticketId'] as String,
  ticketNumber: json['ticketNumber'] as String,
  status: json['status'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$TicketDataToJson(TicketData instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'ticketNumber': instance.ticketNumber,
      'status': instance.status,
      'createdAt': instance.createdAt,
    };

CreateTicketResponse _$CreateTicketResponseFromJson(
  Map<String, dynamic> json,
) => CreateTicketResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: TicketData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateTicketResponseToJson(
  CreateTicketResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
