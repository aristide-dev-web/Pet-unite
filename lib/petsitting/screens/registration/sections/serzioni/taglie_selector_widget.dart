import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'shared_servizi_widgets.dart';

class TaglieSelectorWidget extends StatelessWidget {
  final List<String> currentSelected;
  final Function(String, bool) onTagliaChanged;
  final String? title;

  const TaglieSelectorWidget({
    super.key,
    required this.currentSelected,
    required this.onTagliaChanged,
    this.title,
  });

  static const Color indigoColor = Color(0xFF6366F1);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryTextColor = Color(0xFF64748B);

  static final Map<String, Map<String, dynamic>> taglieInfo = {
    'XS': {'label': 'XS (0kg - 5kg)', 'icon': 'assets/images/xs.png', 'size': 24.0},
    'S': {'label': 'S (5kg - 10kg)', 'icon': 'assets/images/s.png', 'size': 30.0},
    'M': {'label': 'M (10kg - 25kg)', 'icon': 'assets/images/media.png', 'size': 76.0}, 
    'L': {'label': 'L (25kg - 45kg)', 'icon': 'assets/images/grande.png', 'size': 60.0}, 
    'XL': {'label': 'XL (45kg+)', 'icon': 'assets/images/xl.png', 'size': 55.0},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: secondaryTextColor, letterSpacing: 1.2)),
          const SizedBox(height: 15),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.65,
          ),
          itemCount: taglieInfo.length,
          itemBuilder: (context, index) {
            String key = taglieInfo.keys.elementAt(index);
            var info = taglieInfo[key]!;
            bool isSelected = currentSelected.contains(key);
            double iconSize = info['size'] as double;
            
            return GestureDetector(
              onTap: () => onTagliaChanged(key, !isSelected),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? indigoColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isSelected ? indigoColor : Colors.grey.shade200, width: 1.5),
                  boxShadow: isSelected ? [BoxShadow(color: indigoColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          info['icon'] as String, 
                          height: iconSize, 
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Icon(Icons.pets, color: isSelected ? Colors.white : Colors.grey, size: 25)
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key, 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isSelected ? Colors.white : textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        info['label']!.split('(')[1].replaceAll(')', ''), 
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isSelected ? Colors.white.withOpacity(0.8) : secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
