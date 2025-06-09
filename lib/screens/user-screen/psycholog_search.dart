import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:psyconnect/blocs/psychologist/psychologist_bloc.dart';
import 'package:psyconnect/config/category_mapping.dart';
import 'package:psyconnect/models/psychologist.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:psyconnect/screens/homepage.dart';
import 'package:psyconnect/widgets/psycholog_list.dart';

class PsychologSearch extends StatefulWidget {
  final String? selectedCategory;
  const PsychologSearch({super.key, this.selectedCategory});

  @override
  _PsychologSearchState createState() => _PsychologSearchState();
}

class _PsychologSearchState extends State<PsychologSearch> {
  @override
  void initState() {
    super.initState();
    context.read<PsychologistBloc>().add(LoadPsychologist());
  }

  List<PsychologistModel> _filterByCategory(
    List<PsychologistModel> psychologists,
    String category,
  ) {
    final keywords =
        PsychologistCategory.categorySpecializations[category] ?? [];

    return psychologists.where((psych) {
      // Cek apakah ada spesialisasi yang match dengan kategori
      return psych.specializations.any((spec) =>
          keywords.any((keyword) => spec.toLowerCase().contains(keyword)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const Homepage(),
              ),
            );
          },
          child: Container(
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/icons/back1.png"),
              ),
            ),
          ),
        ),
        title: Text(
          "Psikolog",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/icons/more.png"),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocConsumer<PsychologistBloc, PsychologistState>(
          listener: (context, state) {
            if (state is PsychologistError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is PsychologistLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PsychologistLoaded) {
              final filteredList = widget.selectedCategory != null
                  ? _filterByCategory(
                      state.psychologists, widget.selectedCategory!)
                  : state.psychologists;

              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final psych = filteredList[index];
                  return PsychologList(
                    harga: "Rp.${psych.consultationFee}",
                    image: "images/doctor1.png",
                    namaPsikolog: psych.fullName,
                    spesialisasi: psych.specializations.join(", "),
                    psychologId: psych.id,
                  );
                },
              );
            } else if (state is PsychologistError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Tidak ada data psikolog.'));
          },
        ),
      ),
    );
  }
}
