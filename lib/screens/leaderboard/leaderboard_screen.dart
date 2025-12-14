import 'package:flutter/cupertino.dart';
import '../../utils/const_widgets/my_text.dart';
import '../../utils/services/language/language_service.dart';
import '../../utils/ui/colors.dart';
import '../../utils/ui/dimensions.dart';
import '../../utils/widgets/my_button.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  final _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  String _tr(String key) => _languageService.translate(key);

  @override
  Widget build(BuildContext context) {
    final d = Dimensions(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: d.maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(d.space),
                child: Row(
                  children: [
                    MyButton(
                      type: ButtonType.icon,
                      icon: CupertinoIcons.back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text('🏆', style: TextStyle(fontSize: d.iconMedium)),
                    SizedBox(width: d.spaceSmall),
                    MyText(
                      _tr('leaderboard'),
                      fontSize: d.title,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    SizedBox(width: d.backButtonSize),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: d.paddingScreen),
                  child: Center(
                    child: MyText(
                      _tr('coming_soon'),
                      fontSize: d.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}