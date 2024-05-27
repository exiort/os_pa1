#!/bin/bash

dict="submissions"

if [[ ! -d $dict ]]; then
    mkdir -m 755 $dict
fi

cat << EOF > ""$dict"/322_h1_123456789.sh"
#!/bin/bash

for (( i=1; i<101; i++ )); do
    echo \$i >> grading/out.txt
done
EOF


cat << EOF > ""$dict"/322_h1_234567890.sh"
#!/bin/bash

sleep 99999
EOF

cat << EOF > ""$dict"/322_h1_456789123.sh"
#!/bin/bash

for (( i=1; i<81; i++ )); do
    echo \$i >> grading/out.txt
done

for (( i=1; i<21; i++ )); do
    echo \$i >> grading/out.txt
done
EOF

cat << EOF > ""$dict"/CENG322_hw1.sh"
#!/bin/bash

for (( i=1; i<101; i++ )); do
    echo \$i >> grading/out.txt
done
EOF

if [[ ! -f "golden.txt" ]]; then
    for (( i=1; i<101; i++ )); do
        echo $i >> golden.txt
    done
fi