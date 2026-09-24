
clear
echo "Copyright © 2026 Siedel Joshua"
echo ""



# ----------------- Setup files and env -----------------
echo "Starting setup..."

# dd if=/dev/urandom of=big_random_file.bin bs=1M count=100 2> /dev/null
dd if=/dev/urandom of=big_random_file.bin bs=1M count=10 2> /dev/null

MAX_LITTLE_FILES=100

for i in $(seq 1 $MAX_LITTLE_FILES); do
    dd if=/dev/urandom of=little_file_$i.bin bs=1 count=500 2> /dev/null
done

mc alias set server http://localhost:9000 admin admin123 > /dev/null
mc mb server/benchmark > /dev/null

mkdir filesystem

echo "Setup terminated !"
echo ""




# ----------------- Import big file -----------------
echo "----------------- Import big file -----------------"
echo ""


START=$(date +%s%N)
mc cp big_random_file.bin server/benchmark > /dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "MinIO Elapsed Time" "${DURATION}"

START=$(date +%s%N)
cp big_random_file.bin filesystem
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "Filesystem Elapsed Time" "${DURATION}"

echo ""
echo ""




# ----------------- Import little files -----------------
echo "----------------- Import ${MAX_LITTLE_FILES} little files -----------------"
echo ""


START=$(date +%s%N)
for i in $(seq 1 $MAX_LITTLE_FILES); do
    mc cp little_file_$i.bin server/benchmark > /dev/null
done
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "MinIO Elapsed Time" "${DURATION}"

START=$(date +%s%N)
for i in $(seq 1 $MAX_LITTLE_FILES); do
    cp little_file_$i.bin filesystem
done
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "Filesystem Elapsed Time" "${DURATION}"

echo ""
echo ""




# ----------------- Rename -----------------
echo "----------------- Rename bucket/folder -----------------"
echo ""


START=$(date +%s%N)

mc mb server/benchmark-new > /dev/null
mc mv --recursive server/benchmark/ server/benchmark-new/ > /dev/null
mc rb --force server/benchmark > /dev/null

END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "MinIO Elapsed Time" "${DURATION}"

START=$(date +%s%N)
mv filesystem filesystem-new
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "Filesystem Elapsed Time" "${DURATION}"

echo ""
echo ""




# ----------------- List files -----------------
echo "----------------- List files -----------------"
echo ""


START=$(date +%s%N)
mc ls server/benchmark-new/ > /dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "MinIO Elapsed Time" "${DURATION}"

START=$(date +%s%N)
ls filesystem-new/ > /dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "Filesystem Elapsed Time" "${DURATION}"

echo ""
echo ""




# ----------------- Read in middle of file -----------------
echo "----------------- Read middle of file (1 Mo in 10 Mo) -----------------"
echo ""


START=$(date +%s%N)
mc cat --custom-header "Range: bytes=5242880-6291455" server/benchmark-new/big_random_file.bin > /dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "MinIO Elapsed Time" "${DURATION}"

START=$(date +%s%N)
dd if="filesystem-new/big_random_file.bin" bs=1k skip=5120 count=1024 of=/dev/null 2>/dev/null
END=$(date +%s%N)
DURATION=$(( (END - START) / 1000000 ))
printf "%-30s %d ms\n" "Filesystem Elapsed Time" "${DURATION}"

echo ""
echo ""




# ----------------- Cleaning files and env -----------------
echo "Cleaning..."

rm -f big_random_file.bin

for i in $(seq 1 $MAX_LITTLE_FILES); do
    rm -f little_file_$i.bin
done

mc rb --force server/benchmark > /dev/null
mc rb --force server/benchmark-new > /dev/null

mc alias remove server > /dev/null
rm -rf filesystem
rm -rf filesystem-new

echo "Cleaning terminated !"


# read -n 1 -s -p "Press any key to continu..."
# echo ""