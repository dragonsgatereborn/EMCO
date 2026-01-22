#!/usr/bin/env python3
import json
import xml.etree.ElementTree as ET
from pathlib import Path

base_dir = Path("/Users/ricwall/Library/CloudStorage/GoogleDrive-dgatewizzydizzy@gmail.com/.shortcut-targets-by-id/1lU7Zgb6V8CUyG788Ih9xaHfCYvDnYYMQ/dragons_gate/EMCO_temp")
xml_path = base_dir / "build_manual" / "EMCOChat.xml"
src_alias_dir = base_dir / "src" / "aliases" / "EMCO"
src_script_path = base_dir / "src" / "scripts" / "EMCO" / "Code.lua"

pkg_name = "EMCOChat"

# Load alias definitions
aliases_json = json.loads((src_alias_dir / "aliases.json").read_text(encoding="utf-8"))

# Parse XML
parser = ET.XMLParser()
tree = ET.parse(xml_path, parser=parser)
root = tree.getroot()

# Update Code script
for script_group in root.findall(".//ScriptGroup"):
    name_elem = script_group.find("name")
    if name_elem is None:
        continue
    if name_elem.text != "EMCO":
        continue
    for script in script_group.findall("Script"):
        script_name = script.find("name")
        if script_name is not None and script_name.text == "Code":
            script_elem = script.find("script")
            if script_elem is None:
                script_elem = ET.SubElement(script, "script")
            script_elem.text = src_script_path.read_text(encoding="utf-8")
            break
    break

# Find the EMCO AliasGroup
alias_group = None
for group in root.findall(".//AliasGroup"):
    name_elem = group.find("name")
    if name_elem is not None and name_elem.text == "EMCO":
        alias_group = group
        break

if alias_group is None:
    raise SystemExit("Could not find AliasGroup 'EMCO' in XML")

# Build mapping of existing aliases by name
existing = {}
for alias in alias_group.findall("Alias"):
    name_elem = alias.find("name")
    if name_elem is not None:
        existing[name_elem.text] = alias

# Update or add aliases
for alias_def in aliases_json:
    name = alias_def["name"]
    regex = alias_def["regex"]
    filename = name.replace(" ", "_") + ".lua"
    script_path = src_alias_dir / filename
    if not script_path.exists():
        raise SystemExit(f"Missing alias source file: {script_path}")
    script_content = script_path.read_text(encoding="utf-8")
    script_content = script_content.replace("@PKGNAME@", pkg_name)

    alias_elem = existing.get(name)
    if alias_elem is None:
        alias_elem = ET.SubElement(alias_group, "Alias", isActive="yes", isFolder="no")
        ET.SubElement(alias_elem, "name")
        ET.SubElement(alias_elem, "script")
        ET.SubElement(alias_elem, "command")
        ET.SubElement(alias_elem, "packageName")
        ET.SubElement(alias_elem, "regex")

    alias_elem.find("name").text = name
    alias_elem.find("script").text = script_content
    alias_elem.find("regex").text = regex

# Write XML
xml_declaration = "<?xml version='1.0' encoding='utf-8'?>\n"
xml_body = ET.tostring(root, encoding="unicode")
xml_path.write_text(xml_declaration + xml_body, encoding="utf-8")

print("Updated build_manual/EMCOChat.xml from src")
