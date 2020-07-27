library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity processor is
Port (
	clk : in STD_LOGIC;
	reset : in std_logic;
	noopsig: out STD_LOGIC;
	haltsig : out STD_LOGIC);

end processor;
 
architecture Behavioral of  processor is

component MEMORY is
   port(
	clk: in std_logic;
	reset: in std_logic;
	wr_en: in std_logic;
	re_en: in std_logic;
	wr_add: in std_logic_vector(9 downto 0);
	re_add: in std_logic_vector(9 downto 0);
	wr_data: in std_logic_vector(31 downto 0);
	re_data: out std_logic_vector(31 downto 0));
END component;

component alucontrol is
Port (	OP : in STD_LOGIC_VECTOR( 2 DOWNTO 0);
	OPout : out STD_LOGIC_VECTOR( 1 DOWNTO 0);
	Anot : OUT STD_LOGIC;
	Bnot : OUT STD_LOGIC);
END component;

component control is
Port (
	OP : in STD_LOGIC_VECTOR( 3 DOWNTO 0);
	ALUSrc : OUT STD_LOGIC;
	RegRT : OUT STD_LOGIC;
	RegW : out STD_LOGIC;
	MemWrite : out STD_LOGIC;
	MemRead : out STD_LOGIC;
	MemToReg : OUT STD_LOGIC;
	Branch : OUT STD_LOGIC;
	Jalr : out STD_LOGIC;
	Lui : out STD_LOGIC;
	jump : out STD_LOGIC;
	halt : out STD_LOGIC;
	noop : out STD_LOGIC;
	ALUOP : out STD_LOGIC_VECTOR(2 DOWNTO 0));
END component;

component alu is
Port (
	A : in STD_LOGIC_VECTOR( 31 DOWNTO 0);
	B : in STD_LOGIC_VECTOR( 31 DOWNTO 0);
	Anot : in STD_LOGIC;
	Bnot : in STD_LOGIC;
	op : in STD_LOGIC_VECTOR( 1 DOWNTO 0);
	result : out STD_LOGIC_VECTOR( 31 DOWNTO 0);
	overflow : out STD_LOGIC;
	zero : out STD_LOGIC;
	cout : out STD_LOGIC);

end component;

component registerFileGeneric is
   port(
	clk: in std_logic;
	reset: in std_logic;
	wr_en: in std_logic;
	wr_add: in std_logic_vector(3 downto 0);
	re_add1: in std_logic_vector(3 downto 0);
	re_add2: in std_logic_vector(3 downto 0);
	wr_data: in std_logic_vector(31 downto 0);
	re_data1: out std_logic_vector(31 downto 0);
	re_data2: out std_logic_vector(31 downto 0));
END component;

signal add : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sub : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal nandr : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal orr : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal less : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal RealA : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal RealB : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL OPcode :  STD_LOGIC_VECTOR( 3 DOWNTO 0);
SIGNAL	ALUSrc :  STD_LOGIC;
SIGNAL	RegRT :  STD_LOGIC;
SIGNAL	RegWrite :  STD_LOGIC;
SIGNAL	MemWrite :  STD_LOGIC;
SIGNAL	MemRead :  STD_LOGIC;
SIGNAL	MemToReg :  STD_LOGIC;
SIGNAL	Branch : STD_LOGIC;
SIGNAL	Jalr :  STD_LOGIC;
SIGNAL	Lui :  STD_LOGIC;
SIGNAL	halt :  STD_LOGIC;
signal jump : std_logic;
SIGNAL	noop :  STD_LOGIC;
SIGNAL	ALUOPInp :  STD_LOGIC_VECTOR(2 DOWNTO 0);

--SIGNAL	wr_en:  std_logic;
SIGNAL	WriteRegAdd:  std_logic_vector(3 downto 0);
SIGNAL	ReadRegAdd1:  std_logic_vector(3 downto 0);
SIGNAL	ReadRegAdd2:  std_logic_vector(3 downto 0);
SIGNAL	WriteRegData:  std_logic_vector(31 downto 0);
SIGNAL	ReadRegData1:  std_logic_vector(31 downto 0);
SIGNAL	ReadRegData2:  std_logic_vector(31 downto 0);

SIGNAL ALUData1 :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	ALUData2 :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	Anot :  STD_LOGIC;
SIGNAL	Bnot :  STD_LOGIC;
SIGNAL	ALUOP :  STD_LOGIC_VECTOR( 1 DOWNTO 0);
SIGNAL	ALUOutput :  STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL	overflow :  STD_LOGIC;
SIGNAL	zero :  STD_LOGIC;
SIGNAL	cout :  STD_LOGIC;

SIGNAL	WriteMemAdd:  std_logic_vector(9 downto 0);
SIGNAL	ReadMemAdd:  std_logic_vector(9 downto 0);
SIGNAL	WriteMemData:  std_logic_vector(31 downto 0);
SIGNAL	ReadMemData: std_logic_vector(31 downto 0);
SIGNAL	MemReadCon :  STD_LOGIC;
SIGNAL	instruction :  STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	sourcereg :  STD_LOGIC_vector(3 downto 0);
SIGNAL	targetreg :  STD_LOGIC_vector(3 downto 0);
SIGNAL	destreg :  STD_LOGIC_vector(3 downto 0);
SIGNAL	offset :  STD_LOGIC_vector(15 downto 0);
SIGNAL	signedOffset :  STD_LOGIC_vector(31 downto 0);
SIGNAL	ZeroOffset :  STD_LOGIC_vector(31 downto 0);
SIGNAL	LuiOut :  STD_LOGIC_vector(31 downto 0);
SIGNAL	jalrOut :  STD_LOGIC_vector(31 downto 0);
signal waitneeded : std_logic;

SIGNAL textsection :std_logic_vector(9 downto 0):="0011001000";
signal codemode : std_logic;
signal memWritecon : std_logic;
--signal memReadcon : std_logic;
signal memWritepro : std_logic;
signal memReadpro : std_logic;
signal regWritecon : std_logic;
--signal memReadcon : std_logic;
signal regWritepro : std_logic;
SIGNAL	writeData :  STD_LOGIC_vector(31 downto 0);
--signal i : integer:=0;
type romtype is array(6 downto 0) of std_logic_vector(31 downto 0);
   signal rom: romtype:=("00001011001101011111111111100100","00001100000010100000000000000000","00001111000000000000000000000000","00000101000100110000000000101000","00001110000000000000000000000000","00001000000000100000000000011111","00001000000000010000000000001010");
SIGNAL	PC_reg,pc_next, pc_before:  STD_LOGIC_vector(9 downto 0):="0000000000";

TYPE STATE IS (codeapplysig,codeapply,Idle,memIns,halti,continue,waits, datamem,delay);
signal cpustates : state := codeapplysig ;
begin


uutControl : control port map (OPcode,ALUSrc,RegRT,RegWritecon,MemWritecon,MemReadcon ,MemToReg,Branch,Jalr ,Lui,jump, halt,noop,ALUOPInp);

uutALU : alu port map (ALUData1,ALUData2,Anot,Bnot,ALUOP,ALUOutput,Overflow,Zero,Cout);

uutRegisterFile : registerFileGeneric port map (clk,reset,RegWrite,WriteRegAdd,ReadRegAdd1,ReadRegAdd2,WriteRegData,ReadRegData1,ReadRegData2);

uutALUControl : alucontrol port map (ALUOPInp,ALUOP,Anot,Bnot);

uutMemory : MEMORY port map (clk,reset,MemWrite,MemRead,WriteMemAdd,ReadMemAdd,WriteMemData,ReadMemData);

memWrite<=  memWritepro when codemode='1' else
	    memWritecon;
memRead<=  memReadpro when codemode='1' else
	    memReadcon;
RegWrite<= Regwritepro when waitneeded='1' else
	  RegWriteCon;
OPcode<= instruction(27 downto 24);
sourceReg <= instruction(23 downto 20);
targetReg <= instruction(19 downto 16);
destReg <= instruction(15 downto 12);
offset <= instruction(15 downto 0);
ZeroOffset<='0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'& offset;
signedOffset <=offset(15)& offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset(15)&offset;
LuiOut <= offset &'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0';
WriteRegAdd <= (destReg) when RegRt='1' else
		(targetReg);
ReadRegAdd1 <= (sourceReg);
ReadRegAdd2 <= (targetReg);
WriteRegData <= luiOut when Lui='1' else
		'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&'0'&(std_logic_vector((unsigned(pc_before))+4)) when Jalr='1' else
		ALUOutput when MemToReg='1' else
	    	ReadMemData;
ALUdata1<= ReadRegData1;
ALUData2 <= ReadRegData2 when ALUSrc='0' else
	    signedOffset when (opcode="0101") else
	    zeroOffset;

ReadMemAdd <= std_logic_vector(unsigned(PC_reg) + unsigned(TEXTSECTION)) when codemode='1' else
		(ALUOutput(9 downto 0));
WriteMemAdd <= std_logic_vector(unsigned(PC_reg) + unsigned(TEXTSECTION)) when codemode='1' else
		(ALUOutput(9 downto 0));
WriteMemData <= ReadRegData2 when codemode = '0' else
		writeData;
PC_next <= ReadRegData1(9 downto 0) when jalr='1' else 
      zeroOffset(9 downto 0) when Jump='1' else
      std_logic_vector(unsigned(signedoffset(9 downto 0))+(unsigned(pc_reg))+4) when (branch='1' and zero='1') else
      std_logic_vector(unsigned(pc_reg)+4);
PROCESS(CLK,RESET)
variable finished: std_logic:='0';
variable i : integer:=0;
BEGIN

	if( reset='1') then
		pc_reg<="0000000000";
		CPUSTATES<=codeapplysig;
		i:=0;
	elsif( clk'event and clk='1') then
		noopsig<='0';
		haltsig<='0';
	case cpustates is 
		when codeapplysig => 
			MemWritepro<= '1';
			codemode<='1';
			cpustates<=codeapply;
			writeData<= rom(i);
			
 		when codeapply => 
			MemWritepro<= '0';
			codemode<='0';
			textsection<=std_logic_vector(unsigned( textsection)+4);
			i:=i+1;
			cpustates<=codeapplysig;
			if(i=7) then
				finished:='1';
				i:=0;
			end if;
			if(finished = '1') then
				textsection<="0011001000";
				finished:='0';
				cpustates<=waits;
			end if;
		when waits =>	
			MemReadpro <= '1';
			codeMode<='1';
			cpustates<=Idle;
			
			waitneeded<='0';
		when Idle =>
			waitneeded<='0';
			codeMode<='0';
			MemReadpro <= '0';
			i:=i+1;
			instruction<= ReadMemData;
			
			--if(i=5) then
				--finished:='1';
				--i:=0;
			--end if;
			--if(noop='1' ) then
				--noopsig<= '1';
				--cpustates<=memIns;
			--elsif(memReadCon = '1') then
	--			cpustates<= dataMem;
				--MemReadpro <= '0';
				--codeMode<='0';
				--waitneeded<='0';
				--regWritepro<='0';
			--elsif(finished = '1' or halt='1' ) then
			--	finished:='0';
				--cpustates<=halti;
				--waitneeded<='1';
				--regWritepro<='0';
			--else

				MemReadpro <= '0';
				codeMode<='0';
				waitneeded<='1';
				regWritepro<='0';
				cpustates<=memIns;
			--end if;
		
		when delay =>
			pc_reg<=pc_next;
			regWritepro<='0';
			MemReadpro <= '1';
			--regwritepro<='1';
			codeMode<='1';
			cpustates<=Idle;
			waitneeded<='1';
		when memIns => 
			if(memRead= '1') then
				cpustates<= delay;
				MemReadpro <= '0';
				codeMode<='1';
				waitneeded<='1';
				regWritepro<='1';
			elsif(halt='1' ) then
				cpustates<=halti;
				--waitneeded<='1';
				--regWritepro<='0';
			elsif(noop='1') then
				noopsig<='1';
				pc_reg<=pc_next;
				regWritepro<='0';
				MemReadpro <= '1';
				--regwritepro<='1';
				codeMode<='1';
				cpustates<=Idle;
				waitneeded<='0';
			else	
				pc_before<= pc_reg;
				pc_reg<=pc_next;
				regWritepro<='0';
				MemReadpro <= '1';
				--regwritepro<='1';
				codeMode<='1';
				cpustates<=Idle;
				waitneeded<='0';
				--instruction<= ReadMemData;
			end if;	
		when halti => 
				waitneeded<='0';
				haltsig<='1';
		when others =>
		end case;
	end if;
	end process;

end;