import 'package:json_annotation/json_annotation.dart';

part 'support_models.g.dart';

// ============================================================
// EMERGENCY AMBULANCE MODELS
// ============================================================

@JsonSerializable()
class EmergencyNumber {
  final String title;
  final String description;
  final String? phone;
  @JsonKey(name: 'alternativePhone')
  final String? alternativePhone;

  EmergencyNumber({
    required this.title,
    required this.description,
    this.phone,
    this.alternativePhone,
  });

  factory EmergencyNumber.fromJson(Map<String, dynamic> json) =>
      _$EmergencyNumberFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyNumberToJson(this);
}

@JsonSerializable()
class AmbulanceServicesResponse {
  final bool success;
  final String message;
  final AmbulanceServicesData data;

  AmbulanceServicesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AmbulanceServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$AmbulanceServicesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AmbulanceServicesResponseToJson(this);
}

@JsonSerializable()
class AmbulanceServicesData {
  final List<EmergencyNumber> emergencyNumbers;
  final int total;

  AmbulanceServicesData({required this.emergencyNumbers, required this.total});

  factory AmbulanceServicesData.fromJson(Map<String, dynamic> json) =>
      _$AmbulanceServicesDataFromJson(json);
  Map<String, dynamic> toJson() => _$AmbulanceServicesDataToJson(this);
}

// ============================================================
// FAQ MODELS
// ============================================================

@JsonSerializable()
class Faq {
  final String id;
  final String question;
  final String answer;
  final String category;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => _$FaqFromJson(json);
  Map<String, dynamic> toJson() => _$FaqToJson(this);
}

@JsonSerializable()
class FaqResponse {
  final List<Faq> faqs;
  final List<String> categories;

  FaqResponse({required this.faqs, required this.categories});

  factory FaqResponse.fromJson(Map<String, dynamic> json) =>
      _$FaqResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FaqResponseToJson(this);
}

// ============================================================
// TICKET MODELS
// ============================================================

@JsonSerializable()
class CreateTicketRequest {
  final String name;
  final String description;

  CreateTicketRequest({required this.name, required this.description});

  factory CreateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTicketRequestToJson(this);
}

@JsonSerializable()
class TicketData {
  final String ticketId;
  final String ticketNumber;
  final String status;
  final String createdAt;

  TicketData({
    required this.ticketId,
    required this.ticketNumber,
    required this.status,
    required this.createdAt,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) =>
      _$TicketDataFromJson(json);
  Map<String, dynamic> toJson() => _$TicketDataToJson(this);
}

@JsonSerializable()
class CreateTicketResponse {
  final bool success;
  final String message;
  final TicketData data;

  CreateTicketResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTicketResponseToJson(this);
}
@JsonSerializable()
class UserTicket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String status;
  final String priority;
  final String createdAt;
  final String updatedAt;
  final String? assignedAgent;
  final String lastMessage;

  UserTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.assignedAgent,
    required this.lastMessage,
  });

  factory UserTicket.fromJson(Map<String, dynamic> json) =>
      _$UserTicketFromJson(json);
  Map<String, dynamic> toJson() => _$UserTicketToJson(this);
}

@JsonSerializable()
class TicketsData {
  final List<UserTicket> tickets;
  final int total;
  final int open;
  final int resolved;

  TicketsData({
    required this.tickets,
    required this.total,
    required this.open,
    required this.resolved,
  });

  factory TicketsData.fromJson(Map<String, dynamic> json) =>
      _$TicketsDataFromJson(json);
  Map<String, dynamic> toJson() => _$TicketsDataToJson(this);
}

@JsonSerializable()
class TicketsResponse {
  final bool success;
  final String message;
  final TicketsData data;

  TicketsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TicketsResponse.fromJson(Map<String, dynamic> json) =>
      _$TicketsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TicketsResponseToJson(this);
}
