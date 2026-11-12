import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:url_launcher/url_launcher.dart';

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
          const Row(children: [Icon(Icons.system_update_alt, color: Colors.tealAccent, size: 30), SizedBox(width: 10), Expanded(child: Text('MODEL-SPECIFIC FIRMWARE & RECOVERY', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          const Text('Prepare a phone for model-matched firmware recovery, verify firmware files and follow approved manufacturer procedures. Direct flashing is not available in this app.'),
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
        'USB and hardware note: this app scans compatible USB-serial accessories, checks selected firmware files with SHA-256, and provides model-specific preparation and authorized reset guidance. It does not universally detect phones, directly flash or erase connected phones, unlock devices, bypass FRP or change IMEI values. Use official manufacturer tools and verified firmware.',
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
  String? selectedBrand = 'Samsung';
  final model = TextEditingController(text: 'SM-A075F/DS');
  final firmware = TextEditingController();
  final region = TextEditingController();
  final expectedChecksum = TextEditingController();
  PlatformFile? selectedFirmware;
  String? firmwareSha256;
  String firmwareStatus = 'No firmware file selected.';
  bool checkingFirmware = false;
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
          : 'Found ${found.length} compatible USB-serial device(s). USB session refreshed.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { otgMessage = 'USB scan unavailable: $e'; });
    } finally {
      if (mounted) setState(() { scanningOtg = false; });
    }
  }
  Future<void> _checkUsbEraseSupport() async {
    if (scanningOtg) return;
    if (otgDevices.isEmpty) {
      await _scanOtgDevices();
    }
    if (!mounted) return;
    final detected = otgDevices.isNotEmpty;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(detected ? 'USB device detected' : 'No supported USB device found'),
        content: Text(
          detected
            ? 'A USB-serial accessory is visible, but this does not prove that the connected item is an Android phone or that it accepts factory-reset commands. Android has no universal USB-OTG erase command. A target phone must be deliberately enrolled in an authorized device-management setup that supports wiping; otherwise reset it using its own approved recovery/settings process.'
            : 'No compatible USB-serial accessory was detected. Even when a phone is visible over USB, ordinary Android apps cannot universally erase another phone. USB debugging authorization, model-specific support and an authorized reset method are required.',
        ),
        actions: [
          if (isA07) TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _openSupportPage('https://www.samsung.com/uk/apps/smart-switch/');
            },
            child: const Text('Samsung Smart Switch'),
          ),
          if (isA07) TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _openSupportPage('https://update.kies.samsung.com/SmartSwitchPC_recovery_guide/firmware/emergencyrecovery/');
            },
            child: const Text('Emergency recovery instructions'),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }


  Future<void> _openSupportPage(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the support page. Check your internet connection.')),
      );
    }
  }

  void _showAuthorizedResetGuide() {
    final isA07 = isSamsungA07;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Authorized factory reset'),
        content: SingleChildScrollView(child: Text(
          isA07
            ? 'Samsung Galaxy A07 (SM-A075F/DS)\n\n'
              'For a phone you own or are explicitly authorized to service:\n'
              '1. Back up the owner’s data first. A factory reset permanently deletes local user data.\n'
              '2. On the phone, open Settings → General management → Reset → Factory data reset.\n'
              '3. Review the account and data warnings with the owner, then let the owner confirm the reset on the phone.\n'
              '4. For software-update recovery, use a Windows PC or Mac with Samsung Smart Switch. In Smart Switch, open More → Emergency Software Recovery and Initialization, then follow the on-screen instructions if the phone is listed. This is Samsung’s computer-based recovery flow, not an OTG function in this app.\n\n'
              'After reset, Android may require a Google or Samsung account previously synced to the phone (Factory Reset Protection). This app cannot bypass that protection.'
            : 'For a phone you own or are explicitly authorized to service:\n'
              '1. Identify the exact brand and model, and back up the owner’s data.\n'
              '2. Use the manufacturer’s official Settings reset flow or its documented recovery procedure for that exact model.\n'
              '3. The owner must review the warnings and confirm the reset on the target phone.\n'
              '4. If the phone cannot boot, contact the manufacturer or an authorized service centre.\n\n'
              'Reset menus and recovery key combinations differ by model. This app cannot send a universal USB erase command or bypass Google/brand account verification.'
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _resetUsbSession() async {
    if (scanningOtg) return;
    setState(() {
      otgDevices = [];
      scanningOtg = true;
      otgMessage = 'Refreshing the app USB session…';
    });
    // This refreshes this app's USB device list. Android does not expose a
    // general USB-host power-cycle/reset API to ordinary apps.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await _scanOtgDevices();
  }

  final requirements = const [
    'I confirmed the exact model number and hardware variant',
    'Firmware is official, signed and intended for this exact model and region',
    'I backed up important data and obtained the owner’s permission',
    'Battery is sufficiently charged (preferably above 60%)',
    'I have a reliable USB cable and the correct manufacturer USB drivers',
    'I read the manufacturer’s instructions and understand data may be erased',
  ];

  Future<void> _pickFirmware() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false, withData: false);
      if (result == null || result.files.isEmpty) return;
      setState(() { selectedFirmware = result.files.single; firmwareSha256 = null; firmwareStatus = 'Selected. Calculate SHA-256 before relying on this file.'; });
    } catch (e) {
      if (mounted) setState(() => firmwareStatus = 'File selection failed: $e');
    }
  }

  Future<void> _verifyFirmwareFile() async {
    final path = selectedFirmware?.path;
    if (path == null) { setState(() => firmwareStatus = 'Choose a firmware file first.'); return; }
    setState(() { checkingFirmware = true; firmwareStatus = 'Calculating SHA-256…'; });
    try {
      final digest = await sha256.bind(File(path).openRead()).first;
      if (!mounted) return;
      final actual = digest.toString();
      final expected = expectedChecksum.text.trim().toLowerCase();
      setState(() {
        firmwareSha256 = actual;
        firmwareStatus = expected.isEmpty
          ? 'Hash calculated. Compare it with the checksum published by the manufacturer before flashing.'
          : (expected == actual
              ? 'SHA-256 matches the checksum you entered. Confirm the checksum came from the official manufacturer.'
              : 'CHECKSUM MISMATCH. Do not use this firmware file.');
      });
    } catch (e) {
      if (mounted) setState(() => firmwareStatus = 'Could not read or hash this file: $e');
    } finally {
      if (mounted) setState(() => checkingFirmware = false);
    }
  }

  bool get isSamsungA07 =>
      selectedBrand == 'Samsung' &&
      RegExp(r'^SM-A075F(?:/DS)?$', caseSensitive: false).hasMatch(model.text.trim());

  @override
  void dispose() {
    model.dispose();
    firmware.dispose();
    region.dispose();
    expectedChecksum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Firmware flashing assistant')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
        'SAFETY FIRST: Flashing incorrect firmware can permanently damage a phone or erase its data. This assistant can inspect supported USB-serial accessories and prepare model-specific guidance. It cannot universally erase or flash another Android phone over OTG. Use the authorized reset guide for safe, owner-confirmed reset steps.',
        style: TextStyle(fontWeight: FontWeight.w600),
      ))),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.usb, color: Colors.tealAccent, size: 28), SizedBox(width: 8), Expanded(child: Text('USB OTG DEVICE CHECK', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          const Text('Connect the target using a USB OTG adapter, then scan. This checks compatible USB-serial accessories only; it cannot identify every Android phone or erase a connected phone.'),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: scanningOtg ? null : _scanOtgDevices,
            icon: scanningOtg ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
            label: Text(scanningOtg ? 'Scanning…' : 'Scan USB OTG'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: scanningOtg ? null : _resetUsbSession,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Refresh USB device scan'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: scanningOtg ? null : _showAuthorizedResetGuide,
            icon: const Icon(Icons.security),
            label: const Text('Open authorized reset guide'),
          ),
          const SizedBox(height: 8),
          Text(otgMessage),
          ...otgDevices.map((device) => ListTile(
            dense: true, leading: const Icon(Icons.usb),
            title: Text(device.productName ?? device.deviceName ?? 'USB device'),
            subtitle: Text('Vendor ID: ' + (device.vid?.toString() ?? 'unknown') + ' • Product ID: ' + (device.pid?.toString() ?? 'unknown')),
          )),
        ],
      ))),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: selectedBrand,
        decoration: const InputDecoration(labelText: 'Phone brand', border: OutlineInputBorder()),
        items: const ['Samsung', 'Tecno', 'Infinix', 'itel', 'Xiaomi / Redmi / POCO', 'Google Pixel', 'Motorola', 'Nokia / HMD', 'OnePlus', 'OPPO', 'vivo', 'Huawei', 'Realme', 'Other']
          .map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
        onChanged: (value) => setState(() => selectedBrand = value),
      ),
      const SizedBox(height: 10),
      TextField(controller: model, decoration: const InputDecoration(labelText: 'Exact model number / variant', border: OutlineInputBorder())),
      if (selectedBrand == 'Samsung') ...[
        const SizedBox(height: 10),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.verified_user, color: Colors.tealAccent), SizedBox(width: 8), Expanded(child: Text('SAMSUNG GALAXY A07 PROFILE', style: TextStyle(fontWeight: FontWeight.bold)))]),
            SizedBox(height: 8),
            Text('Target device: Galaxy A07 • SM-A075F/DS (model family SM-A075F)'),
            Text('Firmware for SM-A075M is not interchangeable.'),
            SizedBox(height: 6),
            Text('This profile checks the model and firmware family only. It does not unlock the bootloader, write partitions or flash the phone.', style: TextStyle(color: Colors.orangeAccent)),
          ],
        ))),
      ],
      const SizedBox(height: 10),
      TextField(controller: firmware, decoration: const InputDecoration(labelText: 'Official firmware version / build', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: region, decoration: const InputDecoration(labelText: 'Country / region / CSC', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FIRMWARE FILE CHECKER', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _pickFirmware, icon: const Icon(Icons.folder_open), label: const Text('Choose firmware file')),
          if (selectedFirmware != null) Text(selectedFirmware!.name + ' • ' + selectedFirmware!.size.toString() + ' bytes'),
          const SizedBox(height: 8),
          TextField(controller: expectedChecksum, decoration: const InputDecoration(labelText: 'Official SHA-256 checksum (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: checkingFirmware ? null : _verifyFirmwareFile,
            icon: checkingFirmware ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.verified_user),
            label: const Text('Calculate and compare SHA-256'),
          ),
          const SizedBox(height: 8),
          SelectableText(firmwareStatus),
          if (firmwareSha256 != null) SelectableText('SHA-256: ' + firmwareSha256!),
          const SizedBox(height: 6),
          const Text('A matching hash checks file integrity only. It does not prove that firmware is genuine or compatible; obtain the expected hash from the official manufacturer.', style: TextStyle(color: Colors.orangeAccent)),
        ],
      ))),
      const SizedBox(height: 14),
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text(
        'Brand coverage: Samsung, Tecno, Infinix, itel, Xiaomi/Redmi/POCO, Google Pixel, Motorola, Nokia/HMD, OnePlus, OPPO, vivo, Huawei and Realme. Brand selection is preparation guidance, not proof that every model has a supported flashing method.',
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
          final firmwareCode = firmware.text.trim().toUpperCase();
          if (isSamsungA07 && !firmwareCode.startsWith('A075F')) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('For SM-A075F/DS, enter official firmware beginning A075F. Do not use A075M firmware.')));
            return;
          }
          if (selectedBrand == null || model.text.trim().isEmpty || firmware.text.trim().isEmpty || region.text.trim().isEmpty || missing.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(missing.isNotEmpty ? 'Complete every safety check first.' : 'Select brand and enter exact model, firmware and region.')));
            return;
          }
          final deviceName = (selectedBrand ?? '') + ' ' + model.text.trim();
          final message = 'Device: ' + deviceName + '\nFirmware: ' + firmware.text.trim() + '\nRegion: ' + region.text.trim() + '\n\n' +
            (isSamsungA07
              ? 'Samsung Galaxy A07 SM-A075F profile check passed. Confirm CSC and bootloader revision against the official Samsung package. Use Samsung Smart Switch recovery or an authorized Samsung service centre. This app has not flashed or modified the phone.'
              : 'Use only the official manufacturer flashing utility for this exact model. This app has not flashed or modified the phone.');
          showDialog(context: context, builder: (dialogContext) => AlertDialog(
            title: const Text('Preparation checklist complete'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Understood'))],
          ));
        },
        icon: const Icon(Icons.verified_outlined),
        label: const Text('Check flashing readiness'),
      ),
      const SizedBox(height: 14),
      const Text('Not supported by this app: direct USB flashing, bootloader commands, partition writing, universal USB erase, FRP removal, or IMEI changes. Do not use firmware for a similar-looking model.', style: TextStyle(color: Colors.orangeAccent)),
    ]),
  );
}
