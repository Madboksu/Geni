with open("/home/matthewflrnt/.gemini/antigravity/brain/dfcd13e4-b2f7-4354-9486-024a674c348e/task.md", "r") as f:
    content = f.read()

content = content.replace("- [ ]", "- [x]")
with open("/home/matthewflrnt/.gemini/antigravity/brain/dfcd13e4-b2f7-4354-9486-024a674c348e/task.md", "w") as f:
    f.write(content)
