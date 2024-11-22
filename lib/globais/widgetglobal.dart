import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/objects/fuser.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'colorsglobal.dart';

class ContainerBordasFinas extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  const ContainerBordasFinas({super.key, required this.child, this.borderRadius = 10.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            width: 0.5,
            color: Colors.black
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}

class TextoPrincipal extends StatelessWidget {
  final double? fontSize;
  final int? maxLines;
  final String text;
  final TextAlign textAlign;
  const TextoPrincipal({
    super.key,
    required this.text,
    this.fontSize,
    this.maxLines,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(
        fontSize: fontSize,
        color: textoPrincipal
      ),
      maxLines: maxLines,
    );
  }
}

class Carde extends StatelessWidget {
  final Widget child;
  final Color color;
  const Carde({super.key, required this.child, this.color = Colors.white70});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: child,
    );
  }
}

class Avaliacao extends StatelessWidget {
  final double rating;
  final double size;

  const Avaliacao({super.key, required this.rating, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Star(rating: rating, index: index, size: size);
      }),
    );
  }
}

class Star extends StatelessWidget {
  final double rating;
  final int index;
  final double size;

  const Star({super.key, required this.rating, required this.index, required this.size});

  @override
  Widget build(BuildContext context) {
    double partialRating = rating - index;
    return Stack(
      children: [
        Icon(
          Icons.star_border,
          color: Colors.grey,
          size: size,
        ),
        ClipRect(
          clipper: StarClipper(partialRating > 1.0 ? 1.0 : (partialRating < 0 ? 0 : partialRating)),
          child: Icon(
            Icons.star,
            color: Colors.orange,
            size: size,
          ),
        ),
      ],
    );
  }
}

class StarClipper extends CustomClipper<Rect> {
  final double percentage;

  StarClipper(this.percentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0.0, 0.0, size.width * percentage, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}

class BackButao extends StatelessWidget {
  final Color color;
  const BackButao({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: color,
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class CallButton extends StatelessWidget {
  final bool isVideoCall;
  final FUser user;
  const CallButton({
    super.key,
    required this.isVideoCall,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoSendCallInvitationButton(
      buttonSize: const Size(50, 50),
      iconSize: const Size(50, 50),
      clickableBackgroundColor: principal,
      isVideoCall: isVideoCall,
      resourceID: "goodstudy_call",
      invitees: [
        ZegoUIKitUser(
          id: user.uid,
          name: user.nome!,
        ),
      ],
    );
  }
}






