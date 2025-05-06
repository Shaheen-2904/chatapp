import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/network_utils.dart';
import '../view_model/login_view_model.dart';

class LoginScreenWidget extends StatefulWidget {
  final String? role;

  const LoginScreenWidget({super.key, this.role});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginViewModel viewModel;
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String appIcon = '';

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LoginViewModel>(context, listen: false);

    _usernameController.text = "apaims_siddarth";
    _passwordController.text = "apaims@123";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      networkUtils.startTrackingConnection();
    });
    _passwordVisible = false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (_, model, child) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: const Color(0xFFF6F8FB),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF007AFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child:
                                  Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/images/ap_login.png',
                            height: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Andhra Pradesh Agriculture\nInformation & Management System",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "APAIMS 2.0 Chatbot",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Email"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                validator: (value) =>
                                    value!.isEmpty ? "Enter email" : null,
                                decoration: InputDecoration(
                                  hintText: "Enter your email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text("Password"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                validator: (value) =>
                                    value!.isEmpty ? "Enter password" : null,
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Forgot Password ?",
                                      style: TextStyle(
                                        color: Color(0xFF5999F2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              model.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            String userId =
                                                _usernameController.text;
                                            String password =
                                                _passwordController.text;
                                            setState(() {
                                              viewModel.isLoading = true;
                                            });
                                            // await viewModel.authenticate(userId, password, context);
                                            await viewModel.langflowAuthenticate(userId, password, context);
                                       /*     AppState.instance.sessionId = Uuid().v4();
                                            AppState.instance.userId = '5bc7e266-ef3b-4796-99ad-3b9e0bcc97f4';
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ChatWindow(
                                                  isFromHistory: false,
                                                  sessionId: AppState.instance.sessionId,
                                                ),
                                              ),
                                            );*/
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF007AFF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Log In",
                                          style: TextStyle(fontSize: 16,color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
