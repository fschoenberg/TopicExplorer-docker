# link_to_subdirs:: InputDir String -> OutputDir String -> InputFileEnding String
# input and output dir should be absolute paths
function  link_to_subdirs {
  #echo "Eingabe: $1| $2| $3"
  find "$1" -type f -name "*.$3" -printf "%p\0/%P\0" |
  awk -v suffix="$3" -v toprefix="$2" 'BEGIN{FS="/";RS=ORS="\0"}
       NR%2||NF==2 {print $0; next}
       {gsub("\\.", ""); gsub("/","__"); sub("__","/"); gsub(" ","-"); gsub("ä","ae"); gsub("ö","oe");  gsub("ü","ue"); gsub("Ä","Ae"); gsub("Ö","Oe");  gsub("Ü","Ue"); gsub("ß","ss"); gsub("„",""); gsub("“",""); gsub("‚","");  gsub("‘","");  gsub(",","");   gsub("´","");  gsub("+",""); sub(suffix "$","." suffix); print toprefix "/" $0}' |
  #xargs -0 -n2 echo
  xargs -0 -n2 ln -s
}
