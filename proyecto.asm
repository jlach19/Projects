    .data
# Variables para la fecha, hora y alarma
year:       .word 2024
month:      .word 1
day:        .word 1
hour:       .word 12
minute:     .word 0
alarm_hour: .word 12
alarm_minute: .word 0
alarm_am_pm: .asciiz "AM"
alarm_active: .word 0

current_param: .word 0
am_str: .asciiz "AM"
pm_str: .asciiz "PM"
days_in_month: .word 31

# Mensajes para la salida
alarm_msg: .asciiz "[ALARM]"
current_mode: .word 0   # 0: Visualización, 1: Configuración de reloj, 2: Configuración de alarma
am_pm: .asciiz "AM"
prompt: .asciiz "Ingrese comando: "
newline: .asciiz "\n"
space: .asciiz " "
colon: .asciiz ":"
dash: .asciiz "-"
year_label: .asciiz "YEAR"
mo_label: .asciiz "MO"
dd_label: .asciiz "DD"

    .text
main:
    # Loop principal para el reloj
main_loop:
    # Imprimir salto de línea
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4           # Syscall para imprimir string
    la $a0, prompt      # Cargar el prompt
    syscall
    
    li $v0, 12          # Leer un carácter (comando)
    syscall
    move $t0, $v0       # Guardar el comando en $t0

    # Comprobación de comandos
    li $t1, 'M'         # Comando Mode
    beq $t0, $t1, mode

    li $t1, 'S'         # Comando Set
    beq $t0, $t1, set

    li $t1, 'U'         # Comando Up
    beq $t0, $t1, up

    li $t1, 'D'         # Comando Down
    beq $t0, $t1, down

    li $t1, 'T'         # Comando Tick
    beq $t0, $t1, tick
    
    j main_loop

 


mode:
    # Cargar el modo actual
    lw $t0, current_mode

    # Alternar entre los tres modos (0 -> 1 -> 2 -> 0)
    addi $t0, $t0, 1           # Incrementa el modo en 1
    li $t1, 3                  # Hay tres modos en total
    rem $t0, $t0, $t1          # Hacerlo cíclico: 0, 1, 2
    sw $t0, current_mode       # Guardar el nuevo modo

    # Verificar el nuevo modo y saltar a la sección correspondiente
    lw $t0, current_mode
    li $t1, 0                  # Modo de Visualización (0)
    beq $t0, $t1, display_mode

    li $t1, 1                  # Modo de Configuración de Reloj (1)
    beq $t0, $t1, config_clock_mode

    li $t1, 2                  # Modo de Configuración de Alarma (2)
    beq $t0, $t1, config_alarm_mode

    j main_loop

# Modo de Visualización (0)

display_mode:
    # Imprimir salto de línea
    li $v0, 4
    la $a0, newline
    syscall
    
    # Imprimir AM/PM
    li $v0, 4
    la $a0, am_pm          # "AM" o "PM"
    syscall

    # Imprimir espacio
    li $v0, 4
    la $a0, space
    syscall

    # Imprimir la hora
    li $v0, 1
    lw $a0, hour           # Cargar la hora actual
    syscall

    # Imprimir ":"
    li $v0, 4
    la $a0, colon
    syscall

    # Imprimir los minutos
    li $v0, 1
    lw $a0, minute         # Cargar los minutos actuales
    syscall

    # Imprimir espacio
    li $v0, 4
    la $a0, space
    syscall

    # Imprimir el año
    li $v0, 1
    lw $a0, year
    syscall

    # Imprimir "-"
    li $v0, 4
    la $a0, dash
    syscall

    # Imprimir el mes
    li $v0, 1
    lw $a0, month
    syscall

    # Imprimir "-"
    li $v0, 4
    la $a0, dash
    syscall

    # Imprimir el día
    li $v0, 1
    lw $a0, day
    syscall

    # Imprimir salto de línea
    li $v0, 4
    la $a0, newline
    syscall

    # Imprimir encabezados YEAR, MO, DD
    li $v0, 4
    la $a0, year_label
    syscall
    li $v0, 4
    la $a0, space
    syscall
    la $a0, mo_label
    syscall
    li $v0, 4
    la $a0, space
    syscall
    la $a0, dd_label
    syscall

    # Imprimir salto de línea
    li $v0, 4
    la $a0, newline
    syscall

    # Imprimir el calendario mensual
    # Asumiendo que ya tienes una lista de días para el mes, aquí mostramos un ejemplo simplificado
    # Mostrar los días del mes en un formato similar
    # Por simplicidad, muestra los días del 1 al 31 distribuidos en filas de 7 columnas
    
    li $t1, 1                  # Inicializar el contador de días en 1
display_calendar_loop:
    li $v0, 1
    move $a0, $t1              # Imprimir el día actual
    syscall

    # Añadir espacio después del día
    li $v0, 4
    la $a0, space
    syscall

    # Incrementar el contador de días
    addi $t1, $t1, 1

    # Imprimir salto de línea cada 7 días
    li $t2, 7
    rem $t3, $t1, $t2
    beq $t3, $zero, newline_print
    
    # Revisar si llegamos al día 31 y terminamos
    li $t4, 32
    bge $t1, $t4, display_mode_end
    j display_calendar_loop

newline_print:
    li $v0, 4
    la $a0, newline
    syscall
    j display_calendar_loop

display_mode_end:
    # Regresar al bucle principal
    j main_loop


















# Modo de Configuración de Reloj (1)

config_clock_mode:

    # Mostrar el estado actual de la configuración de fecha y hora
    li $v0, 4
    la $a0, space
    syscall

    # Mostrar AM/PM
    li $v0, 4
    la $a0, am_pm
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Mostrar la hora
    li $v0, 1
    lw $a0, hour
    syscall

    # Mostrar los dos puntos para separar hora y minuto
    li $v0, 4
    la $a0, colon
    syscall

    # Mostrar el minuto
    li $v0, 1
    lw $a0, minute
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Mostrar el año
    li $v0, 1
    lw $a0, year
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Mostrar el mes
    li $v0, 1
    lw $a0, month
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    # Mostrar el día
    li $v0, 1
    lw $a0, day
    syscall

    # Volver al bucle principal
    j main_loop

# Subrutina para cambiar el parámetro que se está configurando
set_param:
    lw $t0, current_param       # Cargar el parámetro actual
    addi $t0, $t0, 1            # Incrementar el índice del parámetro
    li $t1, 6                   # Hay seis parámetros en total
    rem $t0, $t0, $t1           # Hacerlo cíclico entre 0 y 5
    sw $t0, current_param       # Guardar el nuevo índice
    j main_loop

# Subrutina para incrementar el valor del parámetro actual
increase_param:
    lw $t0, current_param       # Cargar el parámetro actual
    li $t1, 0                   # Comparar con 0 (AM/PM)
    beq $t0, $t1, toggle_am_pm

    li $t1, 1                   # Comparar con 1 (Hora)
    beq $t0, $t1, increase_hour

    li $t1, 2                   # Comparar con 2 (Minuto)
    beq $t0, $t1, increase_minute

    li $t1, 3                   # Comparar con 3 (Año)
    beq $t0, $t1, increase_year

    li $t1, 4                   # Comparar con 4 (Mes)
    beq $t0, $t1, increase_month

    li $t1, 5                   # Comparar con 5 (Día)
    beq $t0, $t1, increase_day

    j main_loop

# Subrutina para decrementar el valor del parámetro actual
decrease_param:
    lw $t0, current_param       # Cargar el parámetro actual
    li $t1, 0                   # Comparar con 0 (AM/PM)
    beq $t0, $t1, toggle_am_pm

    li $t1, 1                   # Comparar con 1 (Hora)
    beq $t0, $t1, decrease_hour

    li $t1, 2                   # Comparar con 2 (Minuto)
    beq $t0, $t1, decrease_minute

    li $t1, 3                   # Comparar con 3 (Año)
    beq $t0, $t1, decrease_year

    li $t1, 4                   # Comparar con 4 (Mes)
    beq $t0, $t1, decrease_month

    li $t1, 5                   # Comparar con 5 (Día)
    beq $t0, $t1, decrease_day

    j main_loop

































# Modo de Configuración de Alarma (2)
config_alarm_mode:
    # Mostrar el prompt para ajustar la alarma
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, prompt
    syscall

    # Aquí se podrían agregar más líneas para permitir la configuración de la alarma
    # Regresar al bucle principal
    j main_loop

# Función Set
# Parámetro actual (0: AM/PM, 1: hora, 2: minuto, 3: año, 4: mes, 5: día)

set:
    # Cargar el parámetro actual
    lw $t0, current_param
    
    # Incrementar el parámetro actual
    addi $t0, $t0, 1
    li $t1, 6           # Número de parámetros
    rem $t0, $t0, $t1   # Volver a 0 después de 5
    
    # Guardar el nuevo parámetro
    sw $t0, current_param
    
    j main_loop
    

up:
    lw $t0, current_param
    # Revisar qué parámetro está seleccionado y ajustarlo
    # Si es AM/PM
    li $t1, 0
    beq $t0, $t1, toggle_am_pm

    # Si es hora
    li $t1, 1
    beq $t0, $t1, increase_hour

    # Si es minuto
    li $t1, 2
    beq $t0, $t1, increase_minute

    # Si es año
    li $t1, 3
    beq $t0, $t1, increase_year

    # Si es mes
    li $t1, 4
    beq $t0, $t1, increase_month

    # Si es día
    li $t1, 5
    beq $t0, $t1, increase_day

    j main_loop

down:
    lw $t0, current_param
    # Similar a 'up' pero decrece el valor
    # Si es AM/PM
    li $t1, 0
    beq $t0, $t1, toggle_am_pm

    # Si es hora
    li $t1, 1
    beq $t0, $t1, decrease_hour

    # Si es minuto
    li $t1, 2
    beq $t0, $t1, decrease_minute

    # Si es año
    li $t1, 3
    beq $t0, $t1, decrease_year

    # Si es mes
    li $t1, 4
    beq $t0, $t1, decrease_month

    # Si es día
    li $t1, 5
    beq $t0, $t1, decrease_day

    j main_loop


# Función Tick (Incremento de Tiempo)

tick:
    # Incrementar minutos
    lw $t0, minute
    addi $t0, $t0, 1
    li $t1, 60
    bge $t0, $t1, increment_hour
    sw $t0, minute

    # Comprobar alarma
    jal check_alarm

    j main_loop

increment_hour:
    # Resetear minutos y aumentar la hora
    li $t0, 0
    sw $t0, minute
    lw $t0, hour
    addi $t0, $t0, 1
    li $t1, 12
    bge $t0, $t1, toggle_am_pm
    sw $t0, hour

    # Comprobar alarma
    jal check_alarm

    j main_loop

decrease_year:
    lw $t0, year            # Cargar el año actual
    addi $t0, $t0, -1       # Decrementar en 1
    sw $t0, year            # Guardar el nuevo año
    j main_loop             # Regresar al ciclo principal

# Subrutina para decrementar el mes
decrease_month:
    lw $t0, month           # Cargar el mes actual
    addi $t0, $t0, -1       # Decrementar en 1
    li $t1, 1               # Mínimo valor para el mes
    bge $t0, $t1, store_month_dec
    li $t0, 12              # Si el mes baja de 1, volver a 12
store_month_dec:
    sw $t0, month           # Guardar el nuevo mes
    j main_loop             # Regresar al ciclo principal


decrease_hour:
    lw $t0, hour           # Cargar la hora actual
    addi $t0, $t0, -1      # Decrementar la hora en 1
    li $t1, 1              # Mínima hora en formato de 12 horas
    bge $t0, $t1, store_hour_dec  # Si la hora es >= 1, guardar y salir

    # Si la hora es menor que 1, ajustarla a 12 y alternar AM/PM
    li $t0, 12
    jal toggle_am_pm       # Cambiar entre AM y PM cuando se pasa de 1 a 12

store_hour_dec:
    sw $t0, hour           # Guardar la nueva hora
    j main_loop            # Regresar al ciclo principal


decrease_minute:
    # Cargar el valor actual de minutos
    lw $t0, minute
    addi $t0, $t0, -1       # Decrementar en 1
    li $t1, -1              # Comprobar si los minutos son menores a 0
    bgt $t0, $t1, store_minute
    li $t0, 59              # Si los minutos bajan de 0, ajustarlos a 59
    jal decrease_hour       # Llamar a decrease_hour para reducir la hora

store_minute:
    sw $t0, minute          # Guardar el nuevo valor de minutos
    j main_loop             # Regresar al ciclo principal



# Subrutina para decrementar el día
decrease_day:
    lw $t0, day             # Cargar el día actual
    addi $t0, $t0, -1       # Decrementar en 1
    lw $t1, month           # Cargar el mes actual
    li $t2, 1
    bge $t0, $t2, store_day_dec
    jal get_days_in_month   # Llamar a función para obtener los días del mes actual
    move $t0, $v0           # Si el día es menor a 1, ajustar al último día del mes
store_day_dec:
    sw $t0, day             # Guardar el nuevo día
    j main_loop             # Regresar al ciclo principal
    
   
get_days_in_month:
    lw $t0, month           # Cargar el mes actual en $t0
    
    # Enero (31 días)
    li $t1, 1               # Comparar con 1 (enero)
    li $t2, 31              # Número de días en enero
    beq $t0, $t1, return_days

    # Febrero (28 o 29 días)
    li $t1, 2               # Comparar con 2 (febrero)
    beq $t0, $t1, check_leap_year

    # Marzo (31 días)
    li $t1, 3
    li $t2, 31
    beq $t0, $t1, return_days

    # Abril (30 días)
    li $t1, 4
    li $t2, 30
    beq $t0, $t1, return_days

    # Mayo (31 días)
    li $t1, 5
    li $t2, 31
    beq $t0, $t1, return_days

    # Junio (30 días)
    li $t1, 6
    li $t2, 30
    beq $t0, $t1, return_days

    # Julio (31 días)
    li $t1, 7
    li $t2, 31
    beq $t0, $t1, return_days

    # Agosto (31 días)
    li $t1, 8
    li $t2, 31
    beq $t0, $t1, return_days

    # Septiembre (30 días)
    li $t1, 9
    li $t2, 30
    beq $t0, $t1, return_days

    # Octubre (31 días)
    li $t1, 10
    li $t2, 31
    beq $t0, $t1, return_days

    # Noviembre (30 días)
    li $t1, 11
    li $t2, 30
    beq $t0, $t1, return_days

    # Diciembre (31 días)
    li $t1, 12
    li $t2, 31
    beq $t0, $t1, return_days

    # Fin de la lista de meses

check_leap_year:
    lw $t3, year            # Cargar el año actual en $t3
    # Verificar si el año es bisiesto
    li $t4, 4
    rem $t5, $t3, $t4       # $t5 = año % 4
    bne $t5, $zero, feb_days_28  # Si el año no es divisible por 4, febrero tiene 28 días
    
    li $t4, 100
    rem $t5, $t3, $t4       # $t5 = año % 100
    beq $t5, $zero, check_400

    # Año es bisiesto si es divisible por 4 y no por 100
    li $t2, 29              # Febrero tiene 29 días en año bisiesto
    j return_days

check_400:
    li $t4, 400
    rem $t5, $t3, $t4       # $t5 = año % 400
    beq $t5, $zero, feb_days_29

feb_days_28:
    li $t2, 28              # Febrero tiene 28 días si no es año bisiesto
    j return_days

feb_days_29:
    li $t2, 29              # Febrero tiene 29 días en año bisiesto
    j return_days

return_days:
    move $v0, $t2           # Retornar el número de días en $v0
    jr $ra                  # Regresar de la subrutina

 
  
    
# Función de Alarma (muestra ALARM si coincide la hora)
alarm:
    li $v0, 4
    la $a0, alarm_msg
    syscall
    j main_loop

check_alarm:
    lw $t0, hour
    lw $t1, alarm_hour
    bne $t0, $t1, no_alarm

    lw $t0, minute
    lw $t1, alarm_minute
    bne $t0, $t1, no_alarm

    la $a0, alarm_msg
    li $v0, 4
    syscall

no_alarm:
    jr $ra

toggle_am_pm:
    # Cargar la dirección actual de AM/PM
    la $t0, am_pm    # Cargar la dirección de la variable am_pm
    lw $t1, 0($t0)   # Obtener el valor actual de am_pm
    
    # Cargar la dirección de "AM" y comparar
    la $t2, am_str
    beq $t1, $t2, switch_to_pm  # Si es "AM", cambiar a "PM"
    
    # Si no es "AM", cambiar a "AM"
    la $t3, am_str
    sw $t3, 0($t0)
    j main_loop

switch_to_pm:
    la $t3, pm_str
    sw $t3, 0($t0)
    j main_loop
    
    
increase_hour:
    lw $t0, hour
    addi $t0, $t0, 1
    li $t1, 12
    bgt $t0, $t1, reset_hour
    sw $t0, hour
    j main_loop

reset_hour:
    li $t0, 1
    sw $t0, hour
    j main_loop

increase_minute:
    lw $t0, minute
    addi $t0, $t0, 1
    li $t1, 60
    bge $t0, $t1, reset_minute
    sw $t0, minute
    j main_loop

reset_minute:
    li $t0, 0
    sw $t0, minute
    j main_loop

# Subrutina para incrementar el año

increase_year:
    lw $t0, year            # Cargar el año actual
    addi $t0, $t0, 1        # Incrementar en 1
    sw $t0, year            # Guardar el nuevo año
    j main_loop             # Regresar al ciclo principal

# Subrutina para incrementar el mes
increase_month:
    lw $t0, month           # Cargar el mes actual
    addi $t0, $t0, 1        # Incrementar en 1
    li $t1, 12              # Máximo valor para el mes
    ble $t0, $t1, store_month
    li $t0, 1               # Si el mes pasa de 12, volver a 1
store_month:
    sw $t0, month           # Guardar el nuevo mes
    j main_loop             # Regresar al ciclo principal

# Subrutina para incrementar el día
increase_day:
    lw $t0, day             # Cargar el día actual
    addi $t0, $t0, 1        # Incrementar en 1
    lw $t1, month           # Cargar el mes actual
    jal get_days_in_month   # Llamar a función para obtener los días del mes actual
    move $t2, $v0           # Guardar el número de días en $t2
    ble $t0, $t2, store_day
    li $t0, 1               # Si el día excede el límite, reiniciar a 1
store_day:
    sw $t0, day             # Guardar el nuevo día
    j main_loop             # Regresar al ciclo principal
