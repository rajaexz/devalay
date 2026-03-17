
import 'package:devalay_app/src/presentation/contribute/add_dev/devs_widget/add_dev_screen.dart';
import 'package:devalay_app/src/presentation/contribute/add_event/events_widget/add_event_screen.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:devalay_app/src/presentation/create/create_temple/create_temple_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
class CustomDropdownAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final String currentFilter;
  final Function(String?) onFilterChanged;
  final Set<AssetEntity> isSelectMultiple;
  final VoidCallback onPostPressed;

  const CustomDropdownAppBar({
    super.key,
    required this.currentFilter,
    required this.isSelectMultiple,
    required this.onFilterChanged,
    required this.onPostPressed,
  });

  @override
  State<CustomDropdownAppBar> createState() => _CustomDropdownAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _CustomDropdownAppBarState extends State<CustomDropdownAppBar> {
  bool _isMenuOpen = false;

  void _onSelected(String value) {
    setState(() {
      _isMenuOpen = false;
    });

    if (value == 'Add Temple') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CreateTemple()));
    } else if (value == 'Add Event') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddEventScreen()));
    } else if (value == 'Add God') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const AddDevScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.whiteColor
                      : AppColor.greyColor.withOpacity(0.5),
                ),
              ),
              alignment: Alignment.center,
              child: StatefulBuilder(
                builder: (context, setInnerState) {
                  return PopupMenuButton<String>(
                    onCanceled: () {
                      setState(() {
                        _isMenuOpen = false;
                      });
                    },
                    onOpened: () {
                      setState(() {
                        _isMenuOpen = true;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Add Temple',
                        child: Text(StringConstant.addTemple),
                      ),
                      PopupMenuItem(
                        value: 'Add Event',
                        child: Text(StringConstant.addEvent),
                      ),
                      PopupMenuItem(
                        value: 'Add God',
                        child: Text(StringConstant.addGod),
                      ),
                    ],
                    onSelected: _onSelected,
                    offset: const Offset(-15, 30),
               shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
child: Row(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
   SvgPicture.asset( _isMenuOpen  ? "assets/icon/Icon-arrowDown.svg":"assets/icon/Icon-arrow.svg" , width: 10 ,),
      SizedBox(width: 5.w,),
    Text(
      StringConstant.newPostTitle,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),   );
                },
              ),
            ),
            IconButton(
              icon: widget.isSelectMultiple.isNotEmpty
                  ? const Icon(Icons.check, color: Colors.black)
                  : const SizedBox.shrink(),
              onPressed: widget.onPostPressed,
            ),
          ],
        ),
      ),
    );
  }
}
