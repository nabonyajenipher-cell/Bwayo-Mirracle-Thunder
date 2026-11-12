import 'package:flutter/material.dart';

void main() => runApp(const BwayoMiracleThunder());

class BwayoMiracleThunder extends StatelessWidget {
  const BwayoMiracleThunder({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BWAYO MIRACLE THUNDER',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff16c7a2), brightness: Brightness.dark),
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final owner = TextEditingController();
  final brand = TextEditingController();
  final model = TextEditingController();
  final fault = TextEditingController();
  final checks = <String, bool>{};
  final tasks = const [
    'Inspect USB cable and port',
    'Check battery and charging',
    'Test touchscreen',
    'Test speaker and microphone',
    'Test cameras and flash',
    'Check Wi-Fi and Bluetooth',
    'Confirm owner backup',
    'Verify exact firmware model and region',
  ];

  @override
  void dispose() {
    owner.dispose(); brand.dispose(); model.dispose(); fault.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BWAYO MIRACLE THUNDER')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.phone_android, size: 42, color: Colors.tealAccent),
          SizedBox(height: 8),
          Text('Miracle Box Service Centre', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Phone servicing workspace for device records, manual diagnostics, backup checks and firmware preparation.'),
        ],
      ))),
      const SizedBox(height: 12),
      const Text('DEVICE INFORMATION', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _field('Device owner', owner),
      _field('Brand', brand),
      _field('Model / variant', model),
      _field('Reported fault', fault),
      const SizedBox(height: 16),
      const Text('SERVICE CHECKLIST', style: TextStyle(fontWeight: FontWeight.bold)),
      ...tasks.map((task) => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: checks[task] ?? false,
        title: Text(task),
        onChanged: (value) => setState(() => checks[task] = value ?? false),
      )),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () {
          final report = 'BWAYO MIRACLE THUNDER SERVICE REPORT\n'
            'Owner: ${owner.text}\nBrand: ${brand.text}\nModel: ${model.text}\n'
            'Fault: ${fault.text}\n\n'
            'CHECKS\n${tasks.where((t) => checks[t] == true).join('\n')}\n\n'
            'Owner & Founder: BWAYO EMMANUEL';
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Service report'),
            content: SingleChildScrollView(child: SelectableText(report)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ));
        },
        icon: const Icon(Icons.description),
        label: const Text('Generate service report'),
      ),
      const SizedBox(height: 18),
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
        'USB and hardware note: this version provides manual guidance and checklists only. It does not detect devices, communicate with physical Miracle Box hardware, unlock phones, bypass FRP, change IMEI values, download firmware or flash devices. Use official manufacturer tools and verified firmware.',
      ))),
      const Center(child: Padding(
        padding: EdgeInsets.all(12),
        child: Text('Owner & Founder: BWAYO EMMANUEL', style: TextStyle(color: Colors.tealAccent)),
      )),
    ]),
  );

  Widget _field(String label, TextEditingController controller) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );
}
