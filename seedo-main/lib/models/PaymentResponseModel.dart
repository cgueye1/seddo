class PaymentResponseModel {
  final int success;
  final String? token;
  final String? redirectUrl;
  final String? redirect_url;

  PaymentResponseModel({
    required this.success,
    this.token,
    this.redirectUrl,
    this.redirect_url,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      success: json['success'] ?? 0,
      token: json['token'],
      redirectUrl: json['redirectUrl'],
      redirect_url: json['redirect_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'redirectUrl': redirectUrl,
      'redirect_url': redirect_url,
    };
  }
}
