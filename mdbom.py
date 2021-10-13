#
# Example python script to generate a BOM from a KiCad generic netlist
#
# Example: Sorted and Grouped HTML BOM
#
"""
    @package
    Generate a .md BOM list.
    Components are sorted by ref and grouped by value
    Fields are (if exist)
    Ref, Quantity, Value, Datasheet, Description

    Command line:
    python "pathToFile/md_bom.py" "%I" "%O.md"
"""

from __future__ import print_function

# Import the KiCad python helper module and the csv formatter
import os
import sys
sys.path.append("/usr/share/kicad/plugins/")
import kicad_netlist_reader
#import sys

# Start with a basic template
html = """
# <!--SOURCE-->

## <!--DATE-->

## <!--TOOL-->

## <!--COMPCOUNT-->

<!--TABLEROW-->
    """

# Generate an instance of a generic netlist, and load the netlist tree from
# the command line option. If the file doesn't exist, execution will stop
net = kicad_netlist_reader.netlist(sys.argv[1])

# Open a file to write to, if the file cannot be opened output to stdout
# instead
try:
    f = open(sys.argv[2], 'w')
except IOError:
    e = "Can't open output file for writing: " + sys.argv[2]
    print(__file__, ":", e, file=sys.stderr)
    f = sys.stdout

components = net.getInterestingComponents()

# Output a set of rows for a header providing general information
html = html.replace('<!--SOURCE-->', os.path.basename(net.getSource()))
html = html.replace('<!--DATE-->', net.getDate())
html = html.replace('<!--TOOL-->', net.getTool())
html = html.replace('<!--COMPCOUNT-->', "Component Count:" + \
    str(len(components)))

row = "Ref | Qty | Value | Digikey | Datasheet | Description\n"
html = html.replace('<!--TABLEROW-->', row + "<!--TABLEROW-->")

import re
row = re.sub('[^|\n]', '-', row)
html = html.replace('<!--TABLEROW-->', row + "<!--TABLEROW-->")

# Get all of the components in groups of matching parts + values
# (see kicad_netlist_reader.py)
grouped = net.groupComponents(components)

# Output all of the component information
for group in grouped:
    refs = ""

    # Add the reference of every component in the group and keep a reference
    # to the component so that the other data can be filled in once per group
    for component in group:
        if len(refs) > 0:
            refs += ", "
        refs += component.getRef()
        c = component

    row = "" + refs
    row += " | " + str(len(group))
    row += " | " + c.getValue()
    row += " | " + c.getField("Digi-Key_PN")
    row += " | " + c.getDatasheet()
    row += " | " + c.getDescription()
    row += "\n"

    html = html.replace('<!--TABLEROW-->', row + "<!--TABLEROW-->")

html = html.replace('<!--TABLEROW-->', '')

# Print the formatted html to the file
print(html, file=f)
