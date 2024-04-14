import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Dialog(
      backgroundColor: theme.background,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Made with ❤️ by ", style: textTheme.displaySmall),
                //* Link
                MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => launchUrl(Uri(scheme: "https", host: "github.com", path: "Alkali-1234")), child: Text("@Alkali-1234", style: textTheme.displaySmall!.copyWith(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Built with ", style: textTheme.displaySmall),
                MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => launchUrl(Uri(scheme: "https", host: "flutter.dev")), child: Text("Flutter", style: textTheme.displaySmall!.copyWith(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)))),
              ],
            ),
            const SizedBox(height: 10),
            Text("Version 1.0.0", style: textTheme.displaySmall),
            const SizedBox(height: 10),
            Text("""
        Copyright 2024 M. Algazel Faizun
        
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
        
            http://www.apache.org/licenses/LICENSE-2.0
        
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
        
            """, style: textTheme.displaySmall),
          ],
        ),
      ),
    );
  }
}
