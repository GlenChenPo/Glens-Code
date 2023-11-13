f1 = open('out.txt', 'w')
with open("out_valid.txt", 'r') as f2:
    str = [line.rstrip('\n') for line in f2.readlines()]
    if len(str) % 2:
        f1.write("assertion_6 fail\n")
        f1.write("out_valid has to hold for one cycle\n")

f2.close()
f1.close()