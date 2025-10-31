import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';

class StartEndDatePickerSection extends StatefulWidget {
  /// 🔹 كولباك جديد لإرجاع التاريخين المختارين
  final Function(DateTime?, DateTime?)? onDateSelected;

  const StartEndDatePickerSection({super.key, this.onDateSelected});

  @override
  State<StartEndDatePickerSection> createState() =>
      _StartEndDatePickerSectionState();
}

class _StartEndDatePickerSectionState extends State<StartEndDatePickerSection> {
  DateTime? _startSelectedDay;
  DateTime? _endSelectedDay;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _startSelectedDay = DateTime.now();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildTextField(
            context,
            "Start Date",
            _startDateController,
            isStart: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildTextField(
            context,
            "End Date",
            _endDateController,
            isStart: false,
          ),
        ),
      ],
    );
  }

  TextField buildTextField(
    BuildContext context,
    String labelText,
    TextEditingController controller, {
    required bool isStart,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () {
        _selectDate(context, isStart);
      },
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            _selectDate(context, isStart);
          },
          icon: SvgPicture.asset(
            "assets/icons/icon_svg/calendar.svg",
            width: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        labelText: labelText,
        labelStyle: GoogleFonts.raleway(
          color: const Color(0xFF444444),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: "MM/DD/YYYY",
        hintStyle: GoogleFonts.nunito(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E4E7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: ColorSchema.primaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart
        ? (_startSelectedDay ?? DateTime.now())
        : (_endSelectedDay ?? DateTime.now());

    final DateTime? picked = await showRoundedDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.utc(2020, 1, 1),
      lastDate: DateTime.utc(2030, 12, 31),
      borderRadius: 12,
      height: MediaQuery.of(context).size.height * 0.35,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: ColorSchema.primaryColor),
      ),
      styleDatePicker: MaterialRoundedDatePickerStyle(
        textStyleDayButton: GoogleFonts.nunito(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        textStyleButtonPositive: const TextStyle(
          color: ColorSchema.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textStyleButtonNegative: GoogleFonts.nunito(
          textStyle: const TextStyle(
            color: ColorSchema.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundHeader: ColorSchema.primaryColor,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startSelectedDay = picked;
          _startDateController.text =
              '${picked.month}/${picked.day}/${picked.year}';
        } else {
          _endSelectedDay = picked;
          _endDateController.text =
              '${picked.month}/${picked.day}/${picked.year}';
        }
      });

      // 📅 نمرر التواريخ إلى الأب إذا تم تحديد الاثنين أو أحدهما
      widget.onDateSelected?.call(_startSelectedDay, _endSelectedDay);
    }
  }
}
