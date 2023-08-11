import cv2
import numpy as np

# Coordenadas das vagas
vagas = [
    [1, 89, 108, 213],
    [115, 87, 152, 211],
    [289, 89, 138, 212],
    [439, 87, 135, 212],
    [591, 90, 132, 206],
    [738, 93, 139, 204],
    [881, 93, 138, 201],
    [1027, 94, 147, 202]
]

# Carregar o vídeo
video = cv2.VideoCapture('video.mp4')

# Criação do kernel para dilatação
kernel = np.ones((3, 3), np.int8)

# Loop do vídeo
while True:
    # Ler o próximo frame do vídeo
    ret, frame = video.read()

    if not ret:
        video.set(cv2.CAP_PROP_POS_FRAMES, 0)
        continue

    # Converter o frame para escala de cinza
    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Aplicar threshold adaptativo
    frame_th = cv2.adaptiveThreshold(frame_gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 25, 16)

    # Aplicar mediana para remover ruídos
    frame_blur = cv2.medianBlur(frame_th, 5)

    # Dilatar a imagem para melhorar as áreas brancas
    frame_dil = cv2.dilate(frame_blur, kernel)

    # Contagem de vagas abertas
    qt_vagas_abertas = 0

    # Percorrer as vagas
    for x, y, w, h in vagas:
        # Recortar a região de interesse
        roi = frame_dil[y:y + h, x:x + w]

        # Contar pixels brancos
        qt_px_branco = cv2.countNonZero(roi)

        # Desenhar retângulo e texto na imagem
        if qt_px_branco > 3000:
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 3)
        else:
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 3)
            qt_vagas_abertas += 1

        cv2.putText(frame, str(qt_px_branco), (x, y + h - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)

    # Calcular informações adicionais
    qt_vagas_total = len(vagas)
    qt_vagas_ocupadas = qt_vagas_total - qt_vagas_abertas
    porcentagem_vagas_livres = (qt_vagas_abertas / qt_vagas_total) * 100

    # Exibir informações adicionais na imagem
    cv2.putText(frame, "Vagas Totais: " + str(qt_vagas_total), (10, frame.shape[0] - 80), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    cv2.putText(frame, "Vagas Ocupadas: " + str(qt_vagas_ocupadas), (10, frame.shape[0] - 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    cv2.putText(frame, "Vagas Livres: " + str(qt_vagas_abertas), (10, frame.shape[0] - 40), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    cv2.putText(frame, "Porcentagem de Vagas Livres: " + "{:.2f}%".format(porcentagem_vagas_livres), (10, frame.shape[0] - 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    # Exibir o vídeo e o threshold
    cv2.imshow("Video", frame)

    # Esperar por uma tecla pressionada
    key = cv2.waitKey(1) & 0xFF

    # Sair do loop se a tecla "q" for pressionada
    if key == ord('q'):
        break

# Liberar recursos e fechar janelas
video.release()
cv2.destroyAllWindows()
