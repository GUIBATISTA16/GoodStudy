import 'package:projeto_goodstudy/services/auth.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:projeto_goodstudy/globais/widgetglobal.dart';
import '../globais/colorsglobal.dart';
import 'cconta.dart';
import 'package:flutter/material.dart';
import '../globais/varGlobal.dart' as globals;



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {

  final AuthService auth = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  String loginStatus = '';

  bool passwordVisible = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    const appTitle = 'GoodStudy';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        primaryColor: preto,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: preto,
          //selectionColor: preto,
          selectionHandleColor: principal,
        ),
      ),
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.blue[900],
            title: const Text(appTitle,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          backgroundColor: Colors.grey[300],
          body: Builder(builder: (BuildContext context){
            return loading ? const Loading() : Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formkey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ContainerBordasFinas(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                            child: TextFormField(
                              validator: (val) => val!.isEmpty ? 'Insira um email' : null,
                              controller: emailController,
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                            child: TextFormField(
                              obscureText: !passwordVisible,
                              enableSuggestions: false,
                              autocorrect: false,
                              validator: (val) => val!.isEmpty ? 'Insira uma password' : null,
                              controller: passwordController,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),

                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    !passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(formkey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    dynamic result = await auth.signInEmailPassword(emailController.text.trimRight(), passwordController.text.trimRight());
                                    if(result == null){
                                      setState(() {
                                        loading = false;
                                        loginStatus = 'Credenciais inválidas';
                                      });
                                    }
                                    else{
                                      globals.opcao=0;
                                    }
                                  }
                                },
                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(principal)),
                                child: const TextoPrincipal(text: 'Login',fontSize: 20,),
                              ),
                            ),
                          ),
                          if(loginStatus != '')
                            Text(loginStatus,
                              style: TextStyle(
                                color: erro,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  dynamic result = await auth.signInAnon();
                                  if(result == null){
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                                  else{
                                    globals.opcao=3;
                                  }
                                },
                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(principal)),
                                child: const TextoPrincipal(text: 'Login Anónimo',fontSize: 20,),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CriarConta()),
                                  );
                                },
                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(principal)),
                                child: const TextoPrincipal(text: 'Criar Conta',fontSize: 20,),
                              ),
                            ),
                          ),
                          /*ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Teste()),
                              );
                            },
                            child: const Text('Teste'),
                          ),*/
                        ],
                      ),
                    ),

                  ),
                ),
              ),
            );
          },
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loading = false;
    //auth.signOut();
    globals.viewGrupos = 0;
  }
}
