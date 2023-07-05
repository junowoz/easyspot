import cv2
import numpy as np

# Coordenadas pré-definidas das vagas de estacionamento
vagas = [[1, 89, 108, 213],
         [115, 87, 152, 211],
         [289, 89, 138, 212],
         [439, 87, 135, 212],
         [591, 90, 132, 206],
         [738, 93, 139, 204],
         [881, 93, 138, 201],
         [1027, 94, 147, 202]]

# Iniciar a captura de vídeo (0 é geralmente a webcam padrão)
cap = cv2.VideoCapture('http://192.168.0.210:8081/')

# Verificar se a câmera foi aberta corretamente
if not cap.isOpened():
    print("Erro ao abrir a câmera.")
    exit()

# Rodar o vídeo
while True:
    # Lê um frame do vídeo
    check, frame = cap.read()

    # Verificar se o frame foi capturado corretamente
    if not check:
        print("Erro ao ler o frame.")
        break

    # Transforma o frame para escala de cinza
    frameCinza = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY) 

    # Binariza a imagem usando threshold adaptativo para desconsiderar sombras
    frameTh = cv2.adaptiveThreshold(frameCinza, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 25, 16)  

    # Aplica blur mediano para reduzir ruído na imagem
    frameBlur = cv2.medianBlur(frameTh, 5) 

    # Cria um kernel 3x3
    kernel = np.ones((3,3), np.int8) 

    # Aplica dilatação para realçar características na imagem
    frameDil = cv2.dilate(frameBlur, kernel) 

    # Contadores de vagas
    qtVagasAbertas = 0
    qtVagasOcupadas = 0

    # Percorre as coordenadas das vagas 
    for x,y,w,h in vagas:
        # Recorta a imagem para pegar apenas a vaga 
        recorte = frameDil[y:y+h, x:x+w] 

        # Conta quantos pixels brancos tem na imagem
        qtPxBranco = cv2.countNonZero(recorte) 

        # Escreve na imagem a quantidade de pixels brancos
        cv2.putText(frame, str(qtPxBranco), (x,y+h-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,255,255), 1)

        # Cor padrão para vagas desocupadas
        cor = (0, 255, 0) 

        # Verifica se a vaga está ocupada (quantidade de pixels brancos maior que 3000)
        if qtPxBranco > 3000:
            # Muda a cor do retângulo para vermelho
            cor = (0,0,255) 

            # Incrementa o contador de vagas ocupadas
            qtVagasOcupadas += 1
        else:
            # Incrementa o contador de vagas abertas
            qtVagasAbertas += 1

        # Desenha o retângulo da vaga
        cv2.rectangle(frame, (x,y), (x+w, y+h), cor, 3)

    # Calcular a porcentagem de vagas livres
    porcentagemVagasLivres = (qtVagasAbertas / len(vagas)) * 100

    # Escreve as informações na imagem
    info = f"Vagas Abertas: {qtVagasAbertas} | Vagas Ocupadas: {qtVagasOcupadas} | Porcentagem de Vagas Livres: {porcentagemVagasLivres:.2f}%"
    cv2.putText(frame, info, (10, frame.shape[0] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,255), 2, cv2.LINE_AA)

    # Mostra o vídeo
    cv2.imshow("Video", frame)

    # Encerra o loop se 'q' for pressionado
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Libera o objeto de captura de vídeo
cap.release()

# Fecha todas as janelas do OpenCV
cv2.destroyAllWindows()
