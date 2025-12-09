import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'statistics_logic.dart';

class StatisticsPage extends GetView<StatisticsLogic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Diary Statistics',
                    [
                      _buildStatCard('Total Entries', '${controller.diaryStats['totalCount'] ?? 0}'),
                      _buildStatCard('Total Words', '${controller.diaryStats['totalWords'] ?? 0}'),
                      _buildStatCard('Average Words', '${controller.diaryStats['avgWords'] ?? 0}'),
                      if (controller.diaryStats['mostActiveMonth'] != null)
                        _buildStatCard('Most Active Month', controller.diaryStats['mostActiveMonth']),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Note Statistics',
                    [
                      _buildStatCard('Total Notes', '${controller.noteStats['totalCount'] ?? 0}'),
                      _buildStatCard('Total Words', '${controller.noteStats['totalWords'] ?? 0}'),
                      _buildStatCard('Average Words', '${controller.noteStats['avgWords'] ?? 0}'),
                    ],
                  ),
                ],
              ).marginAll(15),
            );
          }),
        ),
      ).decorated(
        image: const DecorationImage(
          image: AssetImage('assets/bg0.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffeaeaea)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

