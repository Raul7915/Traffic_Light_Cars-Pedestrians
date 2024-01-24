module semafor1 (
    input             clk,       	    // semnal de ceas
    input             rst_n,      		// reset
    input             btn,        		// buton pentru pietoni
    output reg [7:0]  led      			// LED output (8 biti)
);


// Stari
reg [2:0] current_state, next_state;

// Timer pentru durata culorii
reg [31:0] timer;


// Parametrii de timp (exemplu: 12 MHz ceas, 4 secunde = 4 * 12,000,000)
parameter VERDE_DURATA  = 48000000;  //'d4;     		// 4 secunde la 12 MHz
parameter GALBEN_DURATA = 36000000;  //'d3;   		    // 3 secunde la 12 MHz
parameter ROSU_DURATA   = 72000000;  //'d5;   		    // 6 secunde la 12 MHz
parameter DELAY_DURATA  = 120000000; //'d6;		    	// 10 secunde pentru verde pietoni dupa apasarea butonului

	// VALORILE COMENTATE DE LA PARAMETRII, DE MAI SUS, SUNT PENTRU SIMULAREA IN MODELSIM.


// Stari pentru semafor
parameter STARE_INITIALA = 3'b000;						// (verde masini - rosu pietoni)
parameter GALBEN_MASINI  = 3'b001;   					// (galben masini - rosu pietoni)
parameter ROSU_MASINI    = 3'b010; 					    // (rosu masini - verde pietoni)
parameter DELAY          = 3'b011;						// (verde masini - rosu pietoni - delay)


// Logica de tranzitie a starii
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        current_state <= STARE_INITIALA;						// La reset - stare initiala + timer setat pe delay
        // timer <= DELAY_DURATA;    				 			//   !!! ACEASTA LINIE O FOLOSIM DOAR IN CAZUL SIMULARII, DEOARECE TIMERUL TREBUIE SA AIBA O VALOARE INITIALA !!!
    end
	else begin
        if (btn && current_state == STARE_INITIALA) begin		// Se asteapta apasarea butonului
            next_state <= GALBEN_MASINI;
        end
		else if (timer == 0) begin
            case (current_state)								// Incepe loop-ul
                STARE_INITIALA: begin							// VERDE (starea initiala)
                    if (btn) begin
                        next_state <= GALBEN_MASINI;
                    end
                end
                GALBEN_MASINI: begin							// GALBEN
                    timer <= GALBEN_DURATA;
                    next_state <= ROSU_MASINI;
                end
                ROSU_MASINI: begin								// ROSU
                    timer <= ROSU_DURATA;
                    next_state <= DELAY;
                end
				DELAY: begin									// STARE INITIALA + DELAY
					timer <= DELAY_DURATA;
					if(btn) begin
					next_state <= STARE_INITIALA;
					end
					else begin
					next_state <= GALBEN_DURATA;
					end
					timer <= 0;
				end

                default: begin									// STAREA INITIALA
                    timer <= 0;
                    next_state <= STARE_INITIALA;
                end

            endcase
            current_state <= next_state;						// Trecerea de la o stare la alta
        end
		else begin
            timer <= timer - 1;									// Decrementarea timer-ului
        end
    end
end


// Logica starii urmatoare si controlul LED-urilor
always @(*) begin
    case (current_state)
        STARE_INITIALA: begin 			// (verde masini - rosu pietoni)
            led = 8'b11011110;
        end
        GALBEN_MASINI: begin 			// (galben masini - rosu pietoni)
            led = 8'b11101110;
        end
        ROSU_MASINI: begin 				// (rosu masini - verde pietoni)
            led = 8'b11110101;
        end
		DELAY: begin					// (verde masini - rosu pietoni - delay)
			led = 8'b01011110;
		end

        default: begin					// (starea initiala)
            led = 8'b11011110;
        end

    endcase
end


endmodule // semafor1
