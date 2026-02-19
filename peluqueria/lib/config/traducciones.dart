import 'package:flutter/material.dart';

extension Trans on String {
  String tr(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    final Map<String, Map<String, String>> data = {
      // --- LOGIN SCREEN ---
      'NOMBRE DE USUARIO': {
        'es': 'NOMBRE DE USUARIO',
        'en': 'USERNAME'
      },
      '¿Olvidaste tu clave?': {
        'es': '¿Olvidaste tu clave?',
        'en': 'Forgot your password?'
      },
      'INICIAR SESIÓN': {
        'es': 'INICIAR SESIÓN',
        'en': 'LOG IN'
      },
      'Continuar con Google': {
        'es': 'Continuar con Google',
        'en': 'Continue with Google'
      },
      '¿Eres nuevo aquí? ': {
        'es': '¿Eres nuevo aquí? ',
        'en': 'Are you new here? '
      },
      'Crea una cuenta': {
        'es': 'Crea una cuenta',
        'en': 'Create an account'
      },
      'Usuario o contraseña incorrectos': {
        'es': 'Usuario o contraseña incorrectos',
        'en': 'Incorrect username or password'
      },
      'Error de conexión con el servidor': {
        'es': 'Error de conexión con el servidor',
        'en': 'Server connection error'
      },

      // --- SIGNUP SCREEN ---
      'UNIRSE A BERNAT': {
        'es': 'UNIRSE A BERNAT',
        'en': 'JOIN BERNAT'
      },
      'USUARIO': {
        'es': 'USUARIO',
        'en': 'USERNAME'
      },
      'NOMBRE COMPLETO': {
        'es': 'NOMBRE COMPLETO',
        'en': 'FULL NAME'
      },
      'EMAIL': {
        'es': 'EMAIL',
        'en': 'EMAIL'
      },
      'TELÉFONO': {
        'es': 'TELÉFONO',
        'en': 'PHONE NUMBER'
      },
      'CONTRASEÑA': {
        'es': 'CONTRASEÑA',
        'en': 'PASSWORD'
      },
      'CONFIRMAR CONTRASEÑA': {
        'es': 'CONFIRMAR CONTRASEÑA',
        'en': 'CONFIRM PASSWORD'
      },
      'Acepto los ': {
        'es': 'Acepto los ',
        'en': 'I accept the '
      },
      'términos y condiciones': {
        'es': 'términos y condiciones',
        'en': 'terms and conditions'
      },
      'CREAR MI CUENTA': {
        'es': 'CREAR MI CUENTA',
        'en': 'CREATE ACCOUNT'
      },
      '¡REGISTRO COMPLETADO!': {
        'es': '¡REGISTRO COMPLETADO!',
        'en': 'REGISTRATION COMPLETE!'
      },
      'Tu cuenta ha sido creada correctamente.': {
        'es': 'Tu cuenta ha sido creada correctamente.',
        'en': 'Your account has been successfully created.'
      },
      'ENTENDIDO': {
        'es': 'ENTENDIDO',
        'en': 'GOT IT'
      },

      // --- FORTALEZA DE CONTRASEÑA ---
      'Contraseña débil': {
        'es': 'Contraseña débil',
        'en': 'Weak password'
      },
      'Contraseña media': {
        'es': 'Contraseña media',
        'en': 'Medium password'
      },
      'Contraseña muy segura': {
        'es': 'Contraseña muy segura',
        'en': 'Strong password'
      },

      // --- VALIDACIONES ---
      'Campo obligatorio': {
        'es': 'Campo obligatorio',
        'en': 'Required field'
      },
      'La contraseña es obligatoria': {
        'es': 'La contraseña es obligatoria',
        'en': 'Password is required'
      },
      'Repite la contraseña': {
        'es': 'Repite la contraseña',
        'en': 'Repeat your password'
      },
      'Introduce tu usuario': {
        'es': 'Introduce tu usuario',
        'en': 'Enter your username'
      },
      'Usuario no válido (4-15 caracteres)': {
        'es': 'Usuario no válido (4-15 caracteres)',
        'en': 'Invalid username (4-15 chars)'
      },
      'Mínimo 8 caracteres': {
        'es': 'Mínimo 8 caracteres',
        'en': 'Min. 8 characters'
      },
      'Debe incluir una mayúscula': {
        'es': 'Debe incluir una mayúscula',
        'en': 'Must include an uppercase letter'
      },
      'Debe incluir al menos un número': {
        'es': 'Debe incluir al menos un número',
        'en': 'Must include at least one number'
      },
      'Falta un símbolo especial (!@#\$&*)': {
        'es': 'Falta un símbolo especial (!@#\$&*)',
        'en': 'Special symbol missing (!@#\$&*)'
      },
      'Las contraseñas no coinciden': {
        'es': 'Las contraseñas no coinciden',
        'en': 'Passwords do not match'
      },
      'Indica tu nombre': {
        'es': 'Indica tu nombre',
        'en': 'Please enter your name'
      },
      'Email no válido': {
        'es': 'Email no válido',
        'en': 'Invalid email address'
      },
      'Deben ser 9 números': {
        'es': 'Deben ser 9 números',
        'en': 'Must be 9 digits'
      },
      'Acepta los términos': {
        'es': 'Acepta los términos',
        'en': 'Accept the terms'
      },
      'El usuario o email ya están registrados': {
        'es': 'El usuario o email ya están registrados',
        'en': 'Username or email already registered'
      },

      // --- TÉRMINOS Y CONDICIONES (TEXTO LEGAL) ---
      'Términos y Condiciones': {
        'es': 'Términos y Condiciones',
        'en': 'Terms and Conditions'
      },
      'Los datos recogidos serán los mínimos necesarios, no se destinarán a otros fines ni se cederán a terceros y se conservarán únicamente durante el tiempo necesario para su finalidad.': {
        'es': 'Los datos recogidos serán los mínimos necesarios, no se destinarán a otros fines ni se cederán a terceros y se conservarán únicamente durante el tiempo necesario para su finalidad.',
        'en': 'The data collected will be the minimum necessary, will not be used for other purposes or transferred to third parties, and will be kept only for as long as necessary.'
      },
      'El cliente podrá ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación del tratamiento y portabilidad solicitándolo al responsable del tratamiento.': {
        'es': 'El cliente podrá ejercer sus derechos de acceso, rectificación, supresión, oposición, limitación del tratamiento y portabilidad solicitándolo al responsable del tratamiento.',
        'en': 'The client may exercise their rights of access, rectification, deletion, opposition, and limitation of processing by contacting the person in charge.'
      },
      'Asimismo, AUTORIZO al salón a realizar y utilizar imágenes (fotografías y/o vídeos) del resultado del servicio con fines informativos y promocionales del propio salón.': {
        'es': 'Asimismo, AUTORIZO al salón a realizar y utilizar imágenes (fotografías y/o vídeos) del resultado del servicio con fines informativos y promocionales del propio salón.',
        'en': 'Furthermore, I AUTHORIZE the salon to take and use images (photos and/or videos) of the service result for salon promotional purposes.'
      },
      'CERRAR': {
        'es': 'CERRAR',
        'en': 'CLOSE'
      },
      'Formato de contraseña incorrecto': {
  'es': 'Formato de contraseña incorrecto',
  'en': 'Incorrect password format'
},
    };

    return data[this]?[lang] ?? this;
  }
}