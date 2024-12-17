.data 
CharPtr1: .word 0          # Biến con trỏ kiểu asciiz 
CharPtr2: .word 0          # Biến con trỏ kiểu asciiz 
ArrayPtr: .word 0          # Biến con trỏ mảng 1 chiều
Array2Ptr: .word 0         # Biến con trỏ mảng 2 chiều
message1: .string "\n\n1. Xu ly mang mot chieu\n"
message2: .string "2. Sao chep mang ky tu\n"
message3: .string "3. Xu ly mang hai chieu\n"
message4: .string "4. Giai phong bo nho\n"
message0.1: .string "So phan tu: "
message0.2: .string "So byte moi phan tu (1 hoac 4): "
message0.3: .string "Nhap phan tu: "
message1.1: .string "Gia tri cua con tro: "
message1.2: .string "\nDia chi cua con tro: "
message1.3: .string "\nTong dia chi da cap phat: "
message2.1: .string "So ky tu toi da: "
message2.2: .string "\nNhap chuoi ky tu: "
message2.3: .string "\nChuoi ky tu duoc copy: "
message3.1: .string "\nSo hang: "
message3.2: .string "\nSo cot: "
message3.3: .string "\n1. getArray[i][j]\n"
message3.4: .string "2. setArray[i][j]\n"
message3.5: .string "3. Thoat\n"
message3.6: .string "\nGia tri cua phan tu: "
message3.01: .string "i = "
message3.02: .string "j = "
message4.1: .string "Da giai phong toan bo bo nho cap phat.\n"
select: .string "Lua chon: "
errmessage: .string "\nSo vua nhap khong hop le.\n"


Sys_TheTopOfFree: .word 1           # Vùng không gian tự do, dùng để cấp bộ nhớ cho các biến con trỏ
Sys_MyFreeSpace:	.space 1024

.text
# Khởi tạo vùng nhớ cấp phát động
jal SysInitMem

menu:
    li a7, 4                    # syscall number for printing string
    la a0, message1              # Load address of message1
    ecall                        # Make syscall

    la a0, message2              # Load address of message2
    ecall                        # Make syscall

    la a0, message3              # Load address of message3
    ecall                        # Make syscall

    la a0, message4              # Load address of message4
    ecall                        # Make syscall

    la a0, select                # Load address of select
    ecall                        # Make syscall

    li a7, 5                     # syscall number for reading integer
    ecall                        # Make syscall (input is in a0)
  
case_1:
    li t0, 1                   # Load immediate value 1 into t0
    bne a0, t0, case_2         # If a0 != 1, jump to case_2

    # Print message0_1
    li a7, 4                   # syscall number for printing string
    la a0, message0.1          # Load address of message0.1
    ecall                       # Make syscall (print string)

    # Read integer input into a0
    li a7, 5                   # syscall number for reading integer
    ecall                       # Make syscall (input will be stored in a0)

    bltz a0, error             # If value in a0 is < 0, jump to error

    addi a1, a0, 0             # Copy value of a0 into a1 using addi

    # Print message0_2
    li a7, 4                   # syscall number for printing string
    la a0, message0.2          # Load address of message0.2
    ecall                       # Make syscall (print message0.2)

    # Read another integer input into a0
    li a7, 5                   # syscall number for reading integer
    ecall                       # Make syscall (input will be stored in a0)

is1: 
    li t0, 1                    # Load immediate value 1 into t0
    beq a0, t0, ready           # If a0 == 1, jump to ready

is4:
    li t1, 4                    # Load immediate value 4 into t1
    beq a0, t1, ready           # If a0 == 4, jump to ready

    j error                     # Jump to error if neither condition is met

ready:
    addi a2, a0, 0              # Copy value from a0 to a2 (no 'move' in RISC-V)
    la a0, ArrayPtr             # Load the address of ArrayPtr into a0
    jal malloc                  # Call malloc to allocate memory
    mv t0, a0                  # Sao chép kết quả malloc (địa chỉ cấp phát) vào t0
    mv a3, t0                  # Khởi tạo a3 bằng địa chỉ bộ nhớ cấp phát (a3 = t0)


    addi t0, a0, 0              # Store the result of malloc into t0 (copying address)

    # Print message0.3
    li a7, 4                    # Syscall number for printing a string
    la a0, message0.3           # Load address of message0.3
    ecall                       # Make syscall (print string)

    addi a0, t0, 0              # Copy the allocated address from t0 into a0
    addi t0, x0, 0              # Set t0 to 0 (clear t0)
    
input_loop: 
    beq t0, a1, input_end       # Nếu t0 == a1, thoát khỏi vòng lặp
    li a7, 5                    # Syscall đọc số nguyên (read integer)
    ecall                       # Gọi syscall, kết quả sẽ lưu vào a0
    
    li t1, 1                    # Gán t1 = 1 để so sánh
    bne a2, t1, byte_4          # Nếu a2 != 1, nhảy tới byte_4

byte_1:
    sb a0, 0(a3)               # Lưu 1 byte từ a0 vào địa chỉ a3
    addi a3, a3, 1             # Tăng con trỏ a3 lên 1 byte
    addi t0, t0, 1             # Tăng bộ đếm t0
    j input_loop               # Quay lại đầu vòng lặp

byte_4:
    sw a0, 0(a3)               # Lưu 4 byte từ a0 vào địa chỉ a3
    addi a3, a3, 4             # Tăng con trỏ a3 lên 4 byte
    addi t0, t0, 1             # Tăng bộ đếm t0
    j input_loop               # Quay lại đầu vòng lặp

input_end: 
    li a7, 4                    # Syscall: in chuỗi (print string)
    la a0, message1.1           # Nạp địa chỉ chuỗi message1.1
    ecall                       # Gọi syscall để in chuỗi

    la a0, ArrayPtr             # Nạp địa chỉ của ArrayPtr vào a0
    jal getValue                # Gọi hàm getValue
    #mv a0, a0                   # Truyền giá trị trả về của hàm vào a0
    li a7, 1                   # Syscall: in địa chỉ (print address)
    ecall                       # Gọi syscall

    li a7, 4                    # Syscall: in chuỗi (print string)
    la a0, message1.2           # Nạp địa chỉ chuỗi message1.2
    ecall                       # Gọi syscall để in chuỗi

    la a0, ArrayPtr             # Nạp địa chỉ của ArrayPtr vào a0
    jal getAddress              # Gọi hàm getAddress
    #mv a0, a0                   # Truyền giá trị trả về của hàm vào a0
    li a7, 1                   # Syscall: in địa chỉ (print address)
    ecall                       # Gọi syscall

    li a7, 4                    # Syscall: in chuỗi (print string)
    la a0, message1.3           # Nạp địa chỉ chuỗi message1.3
    ecall                       # Gọi syscall để in chuỗi

    jal memoryCalculate         # Gọi hàm memoryCalculate
    mv a0, a0                   # Truyền giá trị trả về của hàm vào a0
    li a7, 1                    # Syscall: in số nguyên (print integer)
    ecall                       # Gọi syscall

    j menu                      # Quay lại menu

case_2: 
    li t1, 2                     # Tải hằng số 2 vào t1
    bne a0, t1, case_3           # Nếu a0 != 2 thì nhảy đến case_3

    li a7, 4                     # Syscall: in chuỗi
    la a0, message2.1            # Nạp địa chỉ của message2.1
    ecall                        # Gọi syscall để in chuỗi

    li a7, 5                     # Syscall: nhập số nguyên
    ecall                        # Kết quả sẽ nằm trong a0
    mv a1, a0                    # Lưu số nguyên vào a1
    li a2, 1                     # Gán giá trị 1 cho a2 (sử dụng làm tham số)

    la a0, CharPtr1              # Nạp địa chỉ CharPtr1 vào a0
    jal malloc                   # Gọi hàm malloc để cấp phát bộ nhớ
    mv s0, a0                    # Lưu địa chỉ trả về của malloc vào s0

    la a0, CharPtr2              # Nạp địa chỉ CharPtr2 vào a0
    jal malloc                   # Gọi hàm malloc để cấp phát bộ nhớ
    mv s1, a0                    # Lưu địa chỉ trả về của malloc vào s1

    li a7, 4                     # Syscall: in chuỗi
    la a0, message2.2            # Nạp địa chỉ của message2.2
    ecall                        # Gọi syscall để in chuỗi

    mv a0, s0                    # Truyền địa chỉ CharPtr1 vào a0
    li a7, 8                     # Syscall: nhập chuỗi ký tự
    ecall                        # Gọi syscall để nhập chuỗi

    mv a1, s1                    # Truyền địa chỉ CharPtr2 vào a1
    jal strcpy                   # Gọi hàm strcpy để sao chép chuỗi

    li a7, 4                     # Syscall: in chuỗi
    la a0, message2.3            # Nạp địa chỉ của message2.3
    ecall                        # Gọi syscall để in chuỗi

    mv a0, s1                    # Truyền địa chỉ CharPtr2 vào a0
    li a7, 4                     # Syscall: in chuỗi
    ecall                        # Gọi syscall để in chuỗi đã sao chép

    j menu                       # Quay lại menu

case_3:
    li t1, 3                     # Tải hằng số 3 vào t1
    bne a0, t1, case_4           # Nếu a0 != 3 thì nhảy đến case_4

    # In message3.1
    li a7, 4                     # Syscall 4: In chuỗi
    la a0, message3.1            # Nạp địa chỉ message3.1
    ecall                        # Thực thi syscall

    # Nhập số hàng (rows)
    li a7, 5                     # Syscall 5: Nhập số nguyên
    ecall                        # Kết quả lưu vào a0
    mv a1, a0                    # Lưu số hàng vào a1

    # In message3.2
    li a7, 4                     # Syscall 4: In chuỗi
    la a0, message3.2            # Nạp địa chỉ message3.2
    ecall                        # Thực thi syscall

    # Nhập số cột (columns)
    li a7, 5                     # Syscall 5: Nhập số nguyên
    ecall                        # Kết quả lưu vào a0
    mv a2, a0                    # Lưu số cột vào a2

    # Cấp phát bộ nhớ cho mảng hai chiều
    la a0, Array2Ptr             # Nạp địa chỉ con trỏ mảng hai chiều
    jal malloc2                  # Gọi hàm malloc2 để cấp phát bộ nhớ
    mv t0, a0                    # Lưu địa chỉ được cấp phát vào t0

    # In message0.3
    li a7, 4                     # Syscall 4: In chuỗi
    la a0, message0.3            # Nạp địa chỉ message0.3
    ecall                        # Thực thi syscall

    mv a0, t0                    # Truyền địa chỉ cấp phát vào a0
    li t0, 0                     # Đặt t0 = 0 để khởi tạo vòng lặp (hoặc trạng thái ban đầu)
    mv t1, a1                    # Sao chép số hàng vào t1
    mul a1, a1, a2               # a1 = a1 * a2 (tổng số phần tử mảng hai chiều)

input_loop2: 
    beq t0, a1, input_end2       # Nếu t0 == a1, thoát khỏi vòng lặp
    li a7, 5                     # Syscall: nhập số nguyên (RARS syscall code 5)
    ecall                        # Thực thi syscall
    sw a0, 0(a2)                 # Lưu giá trị nhập vào địa chỉ của a2
    addi a2, a2, 4               # Di chuyển con trỏ a2 đến ô tiếp theo (4 byte)
    addi t0, t0, 1               # Tăng bộ đếm t0 lên 1
    j input_loop2                # Quay lại vòng lặp

input_end2: 
    add a1, zero, t1             # Gán giá trị của t1 vào a1

sub_menu: 
    li a7, 4                     # Syscall: in chuỗi (RARS syscall code 4)
    la a0, message3.3            # Nạp địa chỉ message3_3 vào a0
    ecall                        # Thực thi syscall

    la a0, message3.4            # Nạp địa chỉ message3_4 vào a0
    ecall                        # Thực thi syscall

    la a0, message3.5            # Nạp địa chỉ message3_5 vào a0
    ecall                        # Thực thi syscall

    la a0, select                # Nạp địa chỉ select vào a0
    ecall                        # Thực thi syscall

    li a7, 5                     # Syscall: nhập số nguyên
    ecall                        # Thực thi syscall
sub_case_1: 
    li t1, 1                        # Tải hằng số 1 vào thanh ghi t1
    bne a0, t1, sub_case_2          # Nếu a0 != 1 thì nhảy đến sub_case_2

    # In message3.01
    li a7, 4                       # Syscall: in chuỗi (RARS syscall code 4)
    la a0, message3.01             # Nạp địa chỉ message3_01
    ecall                          # Thực thi syscall

    # Nhập số nguyên và lưu vào s0
    li a7, 5                       # Syscall: nhập số nguyên (RARS syscall code 5)
    ecall                          # Thực thi syscall
    mv s0, a0                      # Lưu kết quả nhập được vào s0

    # In message3.02
    li a7, 4                       # Syscall: in chuỗi
    la a0, message3.02             # Nạp địa chỉ message3_02
    ecall                          # Thực thi syscall

    # Nhập số nguyên và lưu vào s1
    li a7, 5                       # Syscall: nhập số nguyên
    ecall                          # Thực thi syscall
    mv s1, a0                      # Lưu kết quả nhập được vào s1

    # Lấy địa chỉ Array2Ptr và gọi hàm getArray
    la t0, Array2Ptr               # Nạp địa chỉ Array2Ptr vào t0
    lw a0, 0(t0)                   # Nạp giá trị tại địa chỉ Array2Ptr vào a0
    jal getArray                   # Gọi hàm getArray
    mv s2, a0                      # Lưu kết quả trả về từ getArray vào s2

    # In message3.6
    li a7, 4                       # Syscall: in chuỗi
    la a0, message3.6              # Nạp địa chỉ message3_6
    ecall                          # Thực thi syscall

    # In giá trị của s2
    li a7, 1                       # Syscall: in số nguyên (RARS syscall code 1)
    mv a0, s2                      # Truyền giá trị s2 vào a0
    ecall                          # Thực thi syscall

    j sub_menu                     # Quay lại sub_menu
sub_case_2:
    li t1, 2                        # Tải hằng số 2 vào thanh ghi t1
    bne a0, t1, sub_case_3          # Nếu a0 != 2 thì nhảy đến sub_case_3

    # In message3.01
    li a7, 4                       # Syscall: in chuỗi (RARS syscall code 4)
    la a0, message3.01             # Nạp địa chỉ message3.01
    ecall                          # Thực thi syscall

    # Nhập số nguyên và lưu vào s0
    li a7, 5                       # Syscall: nhập số nguyên (RARS syscall code 5)
    ecall                          # Thực thi syscall
    mv s0, a0                      # Lưu kết quả vào s0

    # In message3.02
    li a7, 4                       # Syscall: in chuỗi
    la a0, message3.02             # Nạp địa chỉ message3.02
    ecall                          # Thực thi syscall

    # Nhập số nguyên và lưu vào s1, s2
    li a7, 5                       # Syscall: nhập số nguyên
    ecall                          # Thực thi syscall
    mv s1, a0                      # Lưu vào s1
    mv s2, a0                      # Lưu vào s2 (cùng giá trị)

    # In message0.3
    li a7, 4                       # Syscall: in chuỗi
    la a0, message0.3              # Nạp địa chỉ message0.3
    ecall                          # Thực thi syscall

    # Nhập số nguyên
    li a7, 5                       # Syscall: nhập số nguyên
    ecall                          # Thực thi syscall

    # Lấy địa chỉ Array2Ptr và gọi hàm setArray
    la t0, Array2Ptr               # Nạp địa chỉ Array2Ptr vào t0
    lw a0, 0(t0)                   # Lấy giá trị tại địa chỉ Array2Ptr vào a0
    jal setArray                   # Gọi hàm setArray

    j sub_menu                     # Quay lại sub_menu
sub_case_3:
    li t1, 3                        # Tải giá trị 3 vào t1
    bne a0, t1, error               # Nếu a0 != 3, nhảy đến error

    j menu                          # Nếu a0 == 3, quay lại menu

case_4:
    li t1, 4                        # Tải giá trị 4 vào t1
    bne a0, t1, error               # Nếu a0 != 4, nhảy đến error

    jal free                        # Gọi hàm free

    # In message4.1
    li a7, 4                        # Syscall: in chuỗi
    la a0, message4.1               # Nạp địa chỉ message4.1
    ecall                           # Thực thi syscall

    # In message1.3
    li a7, 4                        # Syscall: in chuỗi
    la a0, message1.3               # Nạp địa chỉ message1.3
    ecall                           # Thực thi syscall

    jal memoryCalculate             # Gọi hàm memoryCalculate

    mv a0, a0                       # Sử dụng lệnh mv thay vì move
    li a7, 1                        # Syscall: in số nguyên
    ecall                           # Thực thi syscall

    j menu                          # Quay lại menu

error:
    li a7, 4                        # Syscall: in chuỗi
    la a0, errmessage               # Nạp địa chỉ errmessage
    ecall                           # Thực thi syscall

    j menu                          # Quay lại menu

SysInitMem:
    la t0, Sys_TheTopOfFree        # Lấy con trỏ tới địa chỉ đầu tiên của vùng bộ nhớ tự do
    la t1, Sys_MyFreeSpace         # Lấy địa chỉ của vùng bộ nhớ tự do hiện tại
    sw t1, 0(t0)                   # Lưu địa chỉ của vùng bộ nhớ tự do vào Sys_TheTopOfFree
    jr ra                          # Quay lại địa chỉ trả về

malloc:
    la t0, Sys_TheTopOfFree        # Lấy con trỏ tới địa chỉ đầu tiên của vùng bộ nhớ tự do
    lw t1, 0(t0)                   # Lấy giá trị tại địa chỉ Sys_TheTopOfFree vào t1 (địa chỉ đầu tiên của vùng bộ nhớ tự do)

    li t2, 4                       # Tải giá trị 4 vào t2 (đại diện cho kích thước của 1 từ - word)
    bne a2, t2, initialize         # Nếu a2 (kích thước phần tử) không phải là 4, nhảy đến phần khởi tạo

    andi t3, t1, 0x03              # Lấy phần dư khi chia địa chỉ bộ nhớ tự do cho 4
    beq t3, x0, initialize         # Nếu phần dư = 0, tức là địa chỉ đã đúng, bỏ qua bước điều chỉnh

    addi t1, t1, 4                 # Nếu không, điều chỉnh địa chỉ đến phần bộ nhớ chia hết cho 4
    sub t1, t1, t3                 # Điều chỉnh địa chỉ (trừ t3 từ t1)

initialize:
    sw t1, 0(a0)                   # Lưu địa chỉ vào biến con trỏ (a0 chứa địa chỉ trả về của malloc)
    addi a0, t1, 0                 # Lưu địa chỉ đã điều chỉnh vào a0 để trả về

    mul t4, a1, a2                 # Tính kích thước của mảng cần cấp phát (a1 là số phần tử, a2 là kích thước mỗi phần tử)
    add t5, t1, t4                 # Tính địa chỉ của con trỏ tiếp theo (địa chỉ mới sau khi cấp phát)

    sw t5, 0(t0)                   # Cập nhật con trỏ Sys_TheTopOfFree với địa chỉ mới sau khi cấp phát
    jr ra                          # Quay lại hàm gọi

# getValue: Lấy giá trị của biến con trỏ
getValue: 
    lw a0, 0(a0)       # Lấy giá trị của biến con trỏ trong ô nhớ có địa chỉ lưu trong $a0
    jr ra               # Quay lại hàm gọi (return)

# getAddress: Lấy địa chỉ từ $a0 và trả về trong $a0
getAddress: 
    add a0, x0, a0      # Lấy địa chỉ từ $a0 và lưu vào $a0 (trả về địa chỉ)
    jr ra               # Quay lại hàm gọi (return)

# strcpy: Sao chép chuỗi từ $a0 (nguồn) sang $a1 (đích)
strcpy:
    add a2, x0, a0       # Khởi tạo $a2 ở đầu chuỗi nguồn (nguồn)
    add a3, x0, a1       # Khởi tạo $a3 ở đầu chuỗi đích (đích)
    
cpyLoop:
    lb a4, 0(a2)         # Đọc ký tự từ chuỗi nguồn (a2)
    beq a4, x0, cpyLoopEnd  # Nếu ký tự là '\0' (end of string), dừng vòng lặp
    sb a4, 0(a3)         # Lưu ký tự vào chuỗi đích (a3)
    
    addi a2, a2, 1       # Chuyển đến ký tự tiếp theo trong chuỗi nguồn
    addi a3, a3, 1       # Chuyển đến ký tự tiếp theo trong chuỗi đích
    j cpyLoop            # Quay lại vòng lặp
    
cpyLoopEnd:
    jr ra                # Trở về

free:
    addi sp, sp, -4        # Tạo không gian 4 byte trên stack
    sw ra, 0(sp)           # Lưu giá trị của $ra vào stack (để quay lại sau khi thực hiện)
    jal SysInitMem         # Gọi hàm SysInitMem (để khởi tạo lại vị trí bộ nhớ)
    lw ra, 0(sp)           # Lấy lại giá trị của $ra từ stack
    addi sp, sp, 4         # Khôi phục lại stack (xóa không gian đã sử dụng)
    jr ra                  # Trở về điểm gọi

memoryCalculate:
    la t0, Sys_MyFreeSpace        # Tải địa chỉ của Sys_MyFreeSpace vào t0
    la t1, Sys_TheTopOfFree       # Tải địa chỉ của Sys_TheTopOfFree vào t1
    lw t2, 0(t1)                  # Tải giá trị tại địa chỉ Sys_TheTopOfFree vào t2 (địa chỉ đầu tiên con trống)
    sub a0, t2, t0                # Tính hiệu giữa hai địa chỉ (t2 - t0), kết quả vào a0
    jr ra                         # Quay lại địa chỉ gọi hàm

malloc2:
    addi sp, sp, -12            # Move stack pointer down by 12 bytes to allocate space for 3 values
    sw ra, 8(sp)                # Save return address into stack (at offset 8)
    sw a1, 4(sp)                # Save a1 (number of rows) into stack (at offset 4)
    sw a2, 0(sp)                # Save a2 (number of columns) into stack (at offset 0)

    mul a1, a1, a2              # a1 = number of rows * number of columns (total elements)
    addi a2, x0, 4              # a2 = 4 (size of one word in bytes)

    jal malloc                  # Call malloc to allocate memory for the array

    lw ra, 8(sp)                # Restore the return address from stack
    lw a1, 4(sp)                # Restore the number of rows from stack
    lw a2, 0(sp)                # Restore the number of columns from stack
    addi sp, sp, 12             # Restore the stack pointer (back to its original position)

    jr ra                       # Return to the calling function

getArray:
    mul t0, s0, a2          # t0 = i * number_of_columns
    add t0, t0, s1          # t0 = t0 + j (i * num_columns + j)
    slli t0, t0, 2          # t0 = t0 * 4 (Shift left by 2, equivalent to multiplying by 4)
    add t0, t0, a0          # t0 = base_address + offset (final address of the element)
    lw a0, 0(t0)            # Load the value into a0 (function return register)
    jr ra                   # Return to caller

setArray:
    mul t0, s0, a2          # t0 = i * number_of_columns
    add t0, t0, s1          # t0 = t0 + j (i * num_columns + j)
    slli t0, t0, 2          # t0 = t0 * 4 (Shift left by 2, equivalent to multiplying by 4)
    add t0, t0, a0          # t0 = base_address + offset (final address of the element)
    sw a1, 0(t0)            # Store the value of a1 into the calculated address
    jr ra                   # Return to caller