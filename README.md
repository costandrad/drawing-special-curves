# Drawing Special Curves

🎨📐 Visualizações e animações de **curvas especiais clássicas** usando **Julia** e o pacote **Luxor.jl**.

Cada curva é organizada como uma **unidade independente**, com seu próprio código, ambiente Julia e outputs, facilitando experimentação, reprodução e expansão do projeto.

---

## ✨ Curvas implementadas

- Astroid
- (em breve) Cardioide
- (em breve) Nefroid
- (em breve) Deltoid
- (em breve) Hipotrocoides / Epitrocoides

---

## 📁 Estrutura do repositório

```text
drawing-special-curves/
│
├── astroid/
│   ├── astroid.jl
│   │
│   ├── outputs/
│   │   ├── frames/        # frames temporários (.png)
│   │   ├── astroid.gif    # animação final (opcional no git)
│   │   └── astroid.mp4
│   │
│   ├── Project.toml
│   └── Manifest.toml
│
├── cardioid/
├── nephroid/
│
└── README.md
