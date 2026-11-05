p = "/Users/nanaminanami/Documents/HiMyDream/日本旅遊報報/japan_train_tour.html"
c = open(p).read()
i = c.find("<footer", c.find("</footer>"))
j = c.find("</footer>", i) + len("</footer>")
print("removing", i, j, c[i:i+80].replace("\n"," "))
c = c[:i] + c[j:]
open(p, "w").write(c)
print("footers left:", c.count("<footer"), "boxes:", c.count('class="tabi-footer-manifesto-box"'))
