#!/usr/bin/env bash 

# idesk configurator
# Paul Groves 2019
# ubuntu/bash@4.x
# idesk of course
# yad

# Check for idesk and idesk files and folders and yad
echo Checking your kit

# Check for yad
  command -v yad >/dev/null 2>&1 || { echo -e  "\n     YAD NOT FOUND     \n" | xmessage -center -file -; exit 1; }
echo found yad

# Checking for idesk is a good idea
  command -v idesk >/dev/null 2>&1 || { echo -e  "\n     IDesk NOT FOUND     \n" | xmessage -center -file -; exit 1; }
echo found idesk
 
# Check for .ideskrc and .idesktop
  if [ -d ${HOME}/.idesktop ] ; then
echo "Desktop exists";
  else
     # DESKTOP DOES NOT EXIST
	  yad --center \
	  --window-icon=gtk-yes \
	  --image "dialog-question" \
	  --borders=20 \
	  --title="ideskrc File Not Found" \
	  --text-align=center \
	  --text="**Desktop folder not found**\n\nCreate it?" \
	  --button=gtk-no:0 \
	  --button=gtk-yes:1 
	  input=$?
      
      if [ "$input" -eq 0 ]; then
		  yad --center --window-icon=gtk-no \
  	      --window-icon=gtk-no \
		  --borders=20 \
		  --width=200 \
		  --title="ideskrc File Not Found" \
		  --text-align=center \
		  --text="<b>Good Bye</b>\n" \
		  --button=gtk-ok:0
		  exit 4
	  else
	     mkdir ${HOME}/.idesktop
	     yad \
	     --title="IDesk Desktop Directory" \
		 --borders=20 \
	     --text="<b> Created Desktop Directory </b>" \
	     
	  fi
   fi
  
  if [ -f ${HOME}/.ideskrc ]; then
    dotFile=${HOME}/.ideskrc
echo using user config
  else 
    dotFile=$(find /  -path $HOME -prune -o -name 'dot.ideskrc' -print 2>/dev/null)
echo using default  config
  fi
echo Kit is up to date

# Array variable names came from the Internet I hope they are right

#  Array of IDesk Options  
  while read line
  do
    optionsArray=( ${optionsArray[@]} $line )
  done <<EndOfArray
		#NULL_Houston_we_have_zero_index_and_FontName_and_Font_Size_inclusive
		Background.Source
		Background.File
		Background.Mode
		Background.Color
		Background.Delay
		FontName
		FontColor
		Bold
		CaptionOnHover
		Shadow
		CaptionPlacement
		ShadowColor
		ShadowX
		ShadowY
		HighContrast
		ToolTip.FontName
		ToolTip.ForeColor
		ToolTip.BackColor
		ToolTip.CaptionOnHover
		ToolTip.CaptionPlacement
		PaddingX
		PaddingY
		Transparency
		FillStyle
		Locked
		IconSnap
		SnapOrigin
		SnapWidth
		SnapHeight
		SnapShadow
		SnapShadowTrans
		ClickDelay
		FontSize
		ToolTip.FontSize
		#Table_Actions
		Lock
		Reload
		Drag
		EndDrag
		Execute\\\[0\\\]
		Execute\\\[1\\\]
EndOfArray

# Loop to read (dot).ideskrc file put options and valid variable names in idesk.array should be in .config
  for i in "${optionsArray[@]}"
  do

   # Skip Commented Line 'NULL' line to take care of zero-index
   echo $i | grep -q ^# && continue

   # create valid variable name replace . with DOT and remove \[]
    variable=`echo "$i" | sed 's/\./DOT/' | sed 's/[^a-zA-Z0-9]//g'`

   # build command line to retrieve value from .ideskrc
	augend=${variable}=

   # Options are in the form of Option.Name':' Option Value
	addend="\`grep -m 1 -e '^[[:blank:]]*"${i}":' ${dotFile} | cut -d: -f2 | sed 's/^ //'\`"
	command="${augend}${addend}"
	eval  $command
  done

# Setup Combo Boxes  
  BackgroundModeCB=`echo 'Stretch!Scale!Center!Fit!Mirror' | sed -e "s/${BackgroundDOTMode}/\^${BackgroundDOTMode}/" `
  CaptionPlacementCB=`echo 'Top!Bottom!Left!Right' | sed "s/${CaptionPlacement}/\^${CaptionPlacement}/" `
  ToolTipPlacementCB=`echo 'Top!Bottom!Left!Right' | sed "s/${ToolTipDOTCaptionPlacement}/\^${ToolTipDOTCaptionPlacement}/" `
  FillStyleCB=`echo 'FillInvert!FillHLine!FillVLine!None' | sed "s/${FillStyle}/\^${FillStyle}/" `
  SnapOriginCB=`echo 'TopLeft!TopRight!BottomLeft!BottomRight' | sed "s/${SnapOrigin}/\^${SnapOrigin}/" `

# Remove "Table Options" from Array
  for n in {1..6}; do
	unset 'optionsArray[${#optionsArray[@]}-1]'
  done

# The font field uses font name and size
  captionFont="$FontName $FontSize"
  tooltipFont="$ToolTipDOTFontName $ToolTipDOTFontSize"

##### Main Dialog #####
  configuration=`yad --width=600 \
	--borders=10 \
	--text-align=center \
	--image-on-top \
	--dialog-sep \
	--add-preview \
	--title="IDesk Configuration" \
	--text="<b> Options for IDesk Configuration </b>\n" \
	--image=/usr/share/idesk/folder_home.xpm  \
    --window-icon=/usr/share/idesk/folder_home.xpm \
   	--separator=":" \
	--form \
   	--fontname="Sans Mono 14" \
    --align=left \
	--columns=3 \
	--field="<b>Background</b>\n   Source":DIR "$BackgroundDOTSource" \
	--field="   File":SFL "$BackgroundDOTFile" \
	--field="   Mode":CB "$BackgroundModeCB" \
	--field="   Color":CLR "$BackgroundDOTColor" \
	--field="\n   Delay (ms)":NUM "$BackgroundDOTDelay"!0..1000!10!0 \
	--field="<b>CAPTION</b>\n   Font":FN  "$captionFont" \
	--field="   Color":CLR "$FontColor" \
	--field=" Bold":CHK "$Bold" \
	--field="   Reveal on Hover":CHK "$CaptionOnHover" \
	--field="   Shadow":CHK "$Shadow" \
	--field="   Placement":CB "$CaptionPlacementCB" \
	--field="<b>CAPTION</b>\n   Shadow Color":CLR  "$ShadowColor" \
	--field="   Shadow X":NUM "$ShadowX"\!0..22\!1\!0 \
	--field="   Shadow Y":NUM "$ShadowY"\!0..22\!1\!0 \
	--field="   High Contrast":CHK "$HighContrast" \
	--field="<b>TOOL TIP</b>\n   Font":FN "$tooltipFont" \
	--field="   Font Color":CLR "$ToolTipDOTForeColor" \
	--field="   Back Color":CLR "$ToolTipDOTBackColor" \
	--field="   Reveal on Hover":CHK "$ToolTipDOTCaptionOnHover" \
	--field="   Placement":CB "$ToolTipPlacementCB" \
	--field="   Padding X":NUM "$PaddingX"\!1..48\!1\!0 \
	--field="   Padding Y":NUM "$PaddingY"\!1..33\!1\!0 \
	--field="<b>ICON</b>\n   Transparency":SCL "$Transparency" \
	--field="Fill Style":CB "$FillStyleCB" \
	--field=" Locked ":CHK "$Locked" \
	--field=" Icon Snap":CHK "$IconSnap" \
	--field="<b>SNAP</b>\n   Origin":CB "$SnapOriginCB" \
	--field="   Width":NUM "$SnapWidth"\!1..100\!1\!0 \
	--field="   Height":NUM "$SnapHeight"\!1..100\!1\!0 \
	--field="Shadow ":CHK "$SnapShadow" \
	--field="   Transparency":SCL "$SnapShadowTrans" \
	--field="Click Delay (ms)":NUM "$ClickDelay"!0..1000!10!0 \
	--field="Edit Actions":FBTN @idesk_table-config.sh  \
	"" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""\
	"" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""`

# Cancel or Close Window Clicked
if [ -z  "$configuration" ]; then 
   echo "Cancel"
    exit 0
fi	

# Print out resulting .ideskrc
echo table Config

for i in "${!optionsArray[@]}"; do 

   # skip comments
     echo ${optionsArray[$i]} | grep -q ^# && continue

   # Remember FN returns Name AND Size
     if [ $(echo ${optionsArray[$i]} | grep  FontSize) ]; then

       # Caption Font Size
        if [ $(echo ${optionsArray[$i]} | grep  ^FontSize) ]; then
           FontSize=`echo  $configuration | cut -d: -f6 | rev | cut -d ' ' -f-1 | rev`
		   echo " FontSize: $FontSize"

	   # Tool Tip Font Size
		else
           ToolTipDOTFontSize=`echo  $configuration | cut -d: -f16 | rev | cut -d ' ' -f-1 | rev`
           echo " ToolTip.FontSize: $ToolTipDOTFontSize"
        fi
        continue
     fi   

   # Generate valid Bash variable names
     variable=`echo ${optionsArray[$i]} | sed 's/\./DOT/' | sed 's/[^a-zA-Z0-9]//g'`

   # extract option value
     command="${variable}=\`echo \${configuration} | cut -d: -f${i}"
      if [ $(echo ${optionsArray[$i]} | grep  FontName) ]; then
         command=$command" | rev | cut -d ' ' -f2- | rev"
      fi
     command=$command"\`"
     eval $command
   # Write Name: Value pair
     command="echo -e \"   ${variable}: \$${variable}\""
     eval $command
done
echo end

# Replace the table Actions
  echo "table Actions"
  echo "Lock:			 $Lock"
  echo "Reload:          $Reload"
  echo "Drag:            $Drag"
  echo "EndDrag:         $EndDrag	"
  echo "Execute[0]:      $Execute0"
  echo "Execute[1]:     $Execute1"
echo end

exit 0
