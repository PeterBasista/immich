import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/modules/asset_viewer/models/image_viewer_page_state.model.dart';
import 'package:immich_mobile/modules/asset_viewer/providers/image_viewer_page_state.provider.dart';
import 'package:immich_mobile/modules/asset_viewer/ui/exif_bottom_sheet.dart';
import 'package:immich_mobile/modules/asset_viewer/ui/remote_photo_view.dart';
import 'package:immich_mobile/modules/home/services/asset.service.dart';
import 'package:immich_mobile/shared/models/asset.dart';
import 'package:immich_mobile/shared/ui/immich_loading_indicator.dart';

// ignore: must_be_immutable
class ImageViewerPage extends HookConsumerWidget {
  final String heroTag;
  final Asset asset;
  final String authToken;
  final ValueNotifier<bool> isZoomedListener;
  final void Function() isZoomedFunction;
  final bool loadPreview;
  final bool loadOriginal;

  ImageViewerPage({
    Key? key,
    required this.heroTag,
    required this.asset,
    required this.authToken,
    required this.isZoomedFunction,
    required this.isZoomedListener,
    required this.loadPreview,
    required this.loadOriginal,
  }) : super(key: key);

  Asset? assetDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadAssetStatus =
        ref.watch(imageViewerStateProvider).downloadAssetStatus;

    getAssetExif() async {
      if (asset.isRemote) {
        assetDetail =
            await ref.watch(assetServiceProvider).getAssetById(asset.id);
      } else {
        // TODO local exif parsing?
        assetDetail = asset;
      }
    }

    useEffect(
      () {
        getAssetExif();
        return null;
      },
      [],
    );

    showInfo() {
      showModalBottomSheet(
        backgroundColor: Colors.black,
        barrierColor: Colors.transparent,
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return ExifBottomSheet(assetDetail: assetDetail ?? asset);
        },
      );
    }

    return Stack(
      children: [
        Center(
          child: Hero(
            tag: heroTag,
            child: RemotePhotoView(
              asset: asset,
              authToken: authToken,
              loadPreview: loadPreview,
              loadOriginal: loadOriginal,
              isZoomedFunction: isZoomedFunction,
              isZoomedListener: isZoomedListener,
              onSwipeDown: () => AutoRouter.of(context).pop(),
              onSwipeUp: asset.isRemote ? showInfo : () {},
            ),
          ),
        ),
        if (downloadAssetStatus == DownloadAssetStatus.loading)
          const Center(
            child: ImmichLoadingIndicator(),
          ),
      ],
    );
  }
}
