# ==========================================
# ALFABETO BASE (Solo minúsculas)
# ==========================================
alfabeto = "abcdefghijklmnopqrstuvwxyz"


# ==========================================
# 1. FUNCION DE CIFRADO
# ==========================================
def cifrar_vigenere(texto, clave):
    texto = texto.lower()
    clave = clave.lower()
    resultado = ""
    indice_clave = 0

    for letra in texto:
        # Solo ciframos si es una letra del alfabeto
        if letra in alfabeto:
            # 1. Posición de la letra del mensaje (ej: 'a' = 0, 'b' = 1...)
            pos_letra = alfabeto.find(letra)

            # 2. Letra actual de la clave y su posición
            letra_clave = clave[indice_clave]
            pos_clave = alfabeto.find(letra_clave)

            # 3. Sumamos ambas posiciones para obtener la nueva letra
            nueva_pos = (pos_letra + pos_clave) % len(alfabeto)
            resultado = resultado + alfabeto[nueva_pos]

            # 4. Pasamos a la siguiente letra de la clave.
            # Si llegamos al final de la palabra clave, volvemos al inicio (0)
            indice_clave = indice_clave + 1
            if indice_clave == len(clave):
                indice_clave = 0
        else:
            # Si es espacio o símbolo, lo dejamos tal cual
            resultado = resultado + letra

    return resultado


# ==========================================
# 2. FUNCION DE DESCIFRADO
# ==========================================
def descifrar_vigenere(texto_cifrado, clave):
    texto_cifrado = texto_cifrado.lower()
    clave = clave.lower()
    resultado = ""
    indice_clave = 0

    for letra in texto_cifrado:
        if letra in alfabeto:
            # 1. Posición de la letra cifrada
            pos_cifrado = alfabeto.find(letra)

            # 2. Letra actual de la clave y su posición
            letra_clave = clave[indice_clave]
            pos_clave = alfabeto.find(letra_clave)

            # 3. Restamos la posición de la clave para regresar a la original
            nueva_pos = (pos_cifrado - pos_clave) % len(alfabeto)
            resultado = resultado + alfabeto[nueva_pos]

            # 4. Avanzamos en la clave (y reiniciamos si termina)
            indice_clave = indice_clave + 1
            if indice_clave == len(clave):
                indice_clave = 0
        else:
            resultado = resultado + letra

    return resultado


# ==========================================
# 3. MENU PRINCIPAL
# ==========================================
def menu():
    continuar = True

    while continuar:
        print("\n-----------------------------")
        print("     CIFRADO VIGENERE")
        print("-----------------------------")
        print("1. Cifrar un mensaje")
        print("2. Descifrar un mensaje")
        print("3. Salir")
        print("-----------------------------")

        opcion = input("Elige una opcion (1, 2 o 3): ")

        if opcion == "1":
            mensaje = input("\nEscribe el mensaje a cifrar: ")
            clave = input("Escribe la clave: ")

            if len(clave) == 0:
                print("Error: Debes ingresar una clave.")
            else:
                cifrado = cifrar_vigenere(mensaje, clave)
                print("Resultado cifrado: " + cifrado)

        elif opcion == "2":
            mensaje_cifrado = input("\nEscribe el mensaje a descifrar: ")
            clave = input("Escribe la clave: ")

            if len(clave) == 0:
                print("Error: Debes ingresar una clave.")
            else:
                descifrado = descifrar_vigenere(mensaje_cifrado, clave)
                print("Resultado descifrado: " + descifrado)

        elif opcion == "3":
            print("\nSaliendo del programa...")
            continuar = False

        else:
            print("\nOpcion no valida, intenta de nuevo.")


# Iniciar el programa
if __name__ == "__main__":
    menu()
