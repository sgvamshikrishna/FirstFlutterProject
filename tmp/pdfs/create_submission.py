from pathlib import Path
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
import zipfile

root = Path.cwd()
out = root / 'submission'
styles = getSampleStyleSheet()
styles['Title'].fontName = 'Helvetica-Bold'
styles['Title'].fontSize = 20
styles['Title'].textColor = colors.black
styles['BodyText'].fontSize = 11
styles['BodyText'].leading = 17
paragraphs = [
'The Flutter Hello World project was prepared on Windows using the existing Flutter SDK installation. Running flutter doctor -v confirmed Flutter 3.47.5 and Dart 3.13.4. The setup was checked against the official Flutter learning pathway and Android setup guide. Flutter was available on the command line, but the diagnostics showed that the Android SDK was missing, and flutter emulators found no configured Android virtual devices. Android Studio, the Android SDK, and a virtual device are still needed to complete mobile testing.',
'The existing Flutter starter project was updated by replacing the counter example in lib/main.dart with a MaterialApp containing an app bar and a centered Text widget that displays Hello World. The starter test was updated to check the greeting and app title. Static analysis completed with no issues, and the widget test passed. These checks verify the code and widget output, but the app has not yet been run on an Android or iOS emulator. A genuine screenshot and confirmation of a successful mobile run must be added before the assignment is submitted.'
]
doc = SimpleDocTemplate(str(out/'hello_world_description.pdf'), pagesize=(612,792), rightMargin=54,leftMargin=54,topMargin=54,bottomMargin=54)
story = [Paragraph('Flutter Hello World App',styles['Title']),Spacer(1,18)]
for p in paragraphs:
    story += [Paragraph(p,styles['BodyText']),Spacer(1,14)]
story += [Spacer(1,10),Paragraph('Official setup references', styles['Heading2'])]
for url in ['https://docs.flutter.dev/learn/pathway','https://docs.flutter.dev/platform-integration/android/setup']:
    story.append(Paragraph(f'<link href="{url}" color="#1756a9">{url}</link>',styles['BodyText']))
doc.build(story)
exclude_dirs = {'.git','.dart_tool','.idea','build','ephemeral','.symlinks','.gradle','submission','tmp'}
exclude_files = {'local.properties','Generated.xcconfig','flutter_export_environment.sh','.flutter-plugins-dependencies'}
with zipfile.ZipFile(out/'hello_world_source.zip','w',zipfile.ZIP_DEFLATED) as z:
    for p in root.rglob('*'):
        rel = p.relative_to(root)
        if p.is_file() and not any(part in exclude_dirs for part in rel.parts) and p.name not in exclude_files and p.suffix not in {'.iml','.log'}:
            z.write(p,Path('hello_world')/rel)
with zipfile.ZipFile(out/'hello_world_source.zip') as z:
    assert z.testzip() is None
    assert 'hello_world/lib/main.dart' in z.namelist()
    print(f'ZIP verified: {len(z.namelist())} source files')
