import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rmbf/main.dart';

// Mock HttpOverrides to avoid NetworkImage exceptions in widget tests
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    if (name.contains('getUrl') || 
        name.contains('get') || 
        name.contains('post') || 
        name.contains('open')) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  final Future<HttpClientResponse> done = Future.value(_MockHttpClientResponse());

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// 1x1 transparent GIF
final List<int> _transparentImage = [
  0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
  0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
  0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
  0x00, 0x02, 0x01, 0x44, 0x00, 0x3b
];

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('RMBF auth flow smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 1. Verify that login screen displays first
    expect(find.text('Welcome to RMBF'), findsOneWidget);
    expect(find.text('Send OTP Verification'), findsOneWidget);

    // 2. Try entering an empty/invalid phone number and verify
    await tester.tap(find.text('Send OTP Verification'));
    await tester.pump();
    expect(find.text('Phone number cannot be empty'), findsOneWidget);

    // 3. Enter a valid 10-digit number
    await tester.enterText(find.byType(TextField), '9865486727');
    await tester.tap(find.text('Send OTP Verification'));
    await tester.pumpAndSettle();

    // 4. Verify OTP screen loads
    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Verify and Login'), findsOneWidget);

    // 5. Enter 4-digit OTP
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(4));
    
    await tester.enterText(textFields.at(0), '1');
    await tester.enterText(textFields.at(1), '2');
    await tester.enterText(textFields.at(2), '3');
    await tester.enterText(textFields.at(3), '4');
    await tester.tap(find.text('Verify and Login'));
    await tester.pumpAndSettle();

    // 6. Verify dashboard loads successfully after OTP validation
    expect(find.text('Santhosh M.R.'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('RMBF sign up flow smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 1. Click "Become a member" on Login Screen
    expect(find.text('Become a member'), findsOneWidget);
    await tester.tap(find.text('Become a member'));
    await tester.pumpAndSettle();

    // 2. Verify Signup Screen loads
    expect(find.text('Become a member'), findsOneWidget);
    expect(find.text('Register & Verify'), findsOneWidget);

    // 3. Try submitting empty form and check validations
    // Scroll down to make validation button visible
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register & Verify'));
    await tester.pump();
    expect(find.text('Name cannot be empty'), findsOneWidget);
    expect(find.text('Phone number cannot be empty'), findsOneWidget);
    expect(find.text('Business name cannot be empty'), findsOneWidget);
    expect(find.text('Vertical interested cannot be empty'), findsOneWidget);

    // Scroll back up to type text fields
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();

    // 4. Enter name, phone, business, and vertical
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'John Doe');
    await tester.enterText(textFields.at(1), '9876543210');
    await tester.enterText(textFields.at(2), 'JD Enterprises');
    await tester.enterText(textFields.at(3), 'Construction Services');
    
    // Scroll down to register button
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.text('Register & Verify'));
    await tester.pumpAndSettle();

    // 5. Verify OTP screen loads for John Doe
    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Enter the 4-digit code sent to +91 9876543210'), findsOneWidget);

    // 6. Enter OTP digits
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(4));
    await tester.enterText(otpFields.at(0), '5');
    await tester.enterText(otpFields.at(1), '6');
    await tester.enterText(otpFields.at(2), '7');
    await tester.enterText(otpFields.at(3), '8');
    
    await tester.tap(find.text('Verify and Login'));
    await tester.pumpAndSettle();

    // 7. Verify dashboard loads with custom name and business details!
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('JD Enterprises'), findsOneWidget);
  });
}
