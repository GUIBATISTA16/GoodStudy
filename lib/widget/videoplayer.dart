import 'package:flutter/material.dart';
import 'package:projeto_goodstudy/widget/loading.dart';
import 'package:video_player/video_player.dart';

class Videoplayer extends StatefulWidget {
  final String url;
  const Videoplayer({super.key, required this.url});

  @override
  State<Videoplayer> createState() => _VideoplayerState();
}

class _VideoplayerState extends State<Videoplayer> {

  late VideoPlayerController videoPlayerController;


  @override
  void dispose() {
    videoPlayerController.pause();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((val){
      videoPlayerController.setLooping(true);
      videoPlayerController.play();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: GestureDetector(
                onTap: (){
                  setState(() {
                    if(videoPlayerController.value.isPlaying){
                      videoPlayerController.pause();
                    }
                    else{
                      videoPlayerController.play();
                    }
                  });
                },
                child: VideoPlayer(videoPlayerController)
              ),
            )
          : const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: Loading(),
          ),),
        VideoProgressIndicator(videoPlayerController, allowScrubbing: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: (){
                videoPlayerController.seekTo(
                  Duration(
                    seconds: videoPlayerController.value.position.inSeconds - 5
                  )
                );
              },
              icon: const Icon(Icons.replay_5, size: 40,)
            ),
            const SizedBox(width: 8,),
            IconButton(
                onPressed: (){
                  setState(() {
                    if(videoPlayerController.value.isPlaying){
                      videoPlayerController.pause();
                    }
                    else{
                      videoPlayerController.play();
                    }
                  });
                },
                icon: videoPlayerController.value.isPlaying
                    ? const Icon(Icons.pause, size: 40,)
                    : const Icon(Icons.play_arrow, size: 40,),
            ),
            const SizedBox(width: 8,),
            IconButton(
                onPressed: (){
                  videoPlayerController.seekTo(
                      Duration(
                          seconds: videoPlayerController.value.position.inSeconds + 5
                      )
                  );
                },
                icon: const Icon(Icons.forward_5, size: 40,)
            ),
          ],
        )
      ],
    );
  }
}
