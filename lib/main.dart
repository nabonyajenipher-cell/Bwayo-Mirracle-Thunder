import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

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

      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.system_update_alt, color: Colors.tealAccent, size: 30), SizedBox(width: 10), Expanded(child: Text('PHONE FIRMWARE FLASHING', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          const Text('Prepare a phone for a safe, model-matched firmware reinstall using official manufacturer software.'),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashAssistantPage())),
            icon: const Icon(Icons.build_circle_outlined), label: const Text('Open flashing assistant'),
          ),
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

class FlashAssistantPage extends StatefulWidget {
  const FlashAssistantPage({super.key});
  @override
  State<FlashAssistantPage> createState() => _FlashAssistantPageState();
}

class _FlashAssistantPageState extends State<FlashAssistantPage> {
  String? selectedBrand;
  final model = TextEditingController();
  final firmware = TextEditingController();
  final region = TextEditingController();
  final checks = <String, bool>{};
  List<UsbDevice> otgDevices = [];
  bool scanningOtg = false;
  String otgMessage = 'Connect a compatible USB-serial device using an OTG adapter, then scan.';
  Future<void> _scanOtgDevices() async {
    setState(() { scanningOtg = true; otgMessage = 'Scanning USB host devices…'; });
    try {
      final found = await UsbSerial.listDevices();
      if (!mounted) return;
      setState(() {
        otgDevices = found;
        otgMessage = found.isEmpty
          ? 'No compatible USB-serial devices detected. Check OTG support, cable, power and USB permission. Phones in bootloader mode may not appear through this serial interface.'
          : 'Found ${found.length} compatible USB-serial device(s).';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { otgMessage = 'USB scan unavailable: $e'; });
    } finally {
      if (mounted) setState(() { scanningOtg = false; });
    }
  }
  final requirements = const [
    'I confirmed the exact model number and hardware variant',
    'Firmware is official, signed and intended for this exact model and region',
    'I backed up important data and obtained the owner’s permission',
    'Battery is sufficiently charged (preferably above 60%)',
    'I have a reliable USB cable and the correct manufacturer USB drivers',
    'I read the manufacturer’s instructions and understand data may be erased',
  ];

  @override
  void dispose() {
    model.dispose(); firmware.dispose(); region.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Firmware flashing assistant')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
        'SAFETY FIRST: Flashing incorrect firmware can permanently damage a phone or erase its data. This assistant prepares a checklist; it does not connect to a phone or perform the flash.',
        style: TextStyle(fontWeight: FontWeight.w600),
      ))),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.usb, color: Colors.tealAccent, size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('USB OTG DEVICE CHECK', style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 8),
          const Text('Connect a compatible USB-serial accessory using a USB OTG adapter. This checks supported USB serial devices; it does not identify every Android phone or perform firmware flashing.'),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: scanningOtg ? null : _scanOtgDevices,
            icon: scanningOtg
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
            label: Text(scanningOtg ? 'Scanning…' : 'Scan USB OTG'),
          ),
          const SizedBox(height: 8),
          Text(otgMessage),
          ...otgDevices.map((device) => ListTile(
            dense: true,
            leading: const Icon(Icons.usb),
            title: Text(device.productName ?? device.deviceName ?? 'USB device'),
            subtitle: Text('Vendor ID: ${device.vid ?? 'unknown'} • Product ID: ${device.pid ?? 'unknown'}'),
          )),
        ],
      ))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: selectedBrand,
        decoration: const InputDecoration(labelText: 'Phone brand', border: OutlineInputBorder()),
        items: const [
          'Samsung', 'Tecno', 'Infinix', 'itel', 'Xiaomi / Redmi / POCO',
          'Google Pixel', 'Motorola', 'Nokia / HMD', 'OnePlus', 'OPPO',
          'vivo', 'Huawei', 'Realme', 'Other',
        ].map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
        onChanged: (value) => setState(() => selectedBrand = value),
      ),
      const SizedBox(height: 10),
      TextField(controller: model, decoration: const InputDecoration(labelText: 'Exact model number / variant', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: firmware, decoration: const InputDecoration(labelText: 'Official firmware version / build', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: region, decoration: const InputDecoration(labelText: 'Country / region / CSC', border: OutlineInputBorder())),

      const SizedBox(height: 14),
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
        'Brand coverage: Samsung, Tecno, Infinix, itel, Xiaomi/Redmi/POCO, Google Pixel, Motorola, Nokia/HMD, OnePlus, OPPO, vivo, Huawei and Realme are available in the device selector. This is brand selection and preparation guidance, not proof that every model has a supported flashing method. Check the exact model with its manufacturer before proceeding.',
      ))),

      const SizedBox(height: 18),
      const Text('BEFORE YOU FLASH', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      ...requirements.map((item) => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: checks[item] ?? false,
        title: Text(item),
        onChanged: (value) => setState(() => checks[item] = value ?? false),
      )),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () {
          final missing = requirements.where((item) => checks[item] != true).toList();
          if (selectedBrand == null || model.text.trim().isEmpty || firmware.text.trim().isEmpty || region.text.trim().isEmpty || missing.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(missing.isNotEmpty ? 'Complete every safety check first.' : 'Select the brand and enter the exact model, firmware and region.'),
            ));
            return;
          }
          showDialog(context: context, builder: (dialogContext) => AlertDialog(
            title: const Text('Preparation checklist complete'),
            content: Text(
              'Device: ' + (selectedBrand ?? '') + ' ' + model.text.trim() + '\n'
              'Firmware: ' + firmware.text.trim() + '\n'
              'Region: ' + region.text.trim() + '\n\n'
              'Use only the official manufacturer flashing utility and its instructions for this exact model. This app has not flashed or modified the phone.',
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Understood'))],
          ));
        },
        icon: const Icon(Icons.verified_outlined),
        label: const Text('Check flashing readiness'),
      ),
      const SizedBox(height: 14),
      const Text(
        'Not supported by this app yet: direct USB flashing, bootloader commands, partition writing, FRP removal, or IMEI changes. Do not use firmware for a similar-looking model.',
        style: TextStyle(color: Colors.orangeAccent),
      ),
    ]),
  );
}
