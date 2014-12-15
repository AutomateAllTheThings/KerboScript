shoulder1:DOACTION("Move +", TRUE).
shoulder3:DOACTION("Move -", TRUE).
shoulder5:DOACTION("Move +", TRUE).
shoulder7:DOACTION("Move -", TRUE).
shoulder9:DOACTION("Move +", TRUE).
shoulder11:DOACTION("Move -", TRUE).

shoulder2:DOACTION("Move -", TRUE).
shoulder4:DOACTION("Move +", TRUE).
shoulder6:DOACTION("Move -", TRUE).
shoulder8:DOACTION("Move +", TRUE).
shoulder10:DOACTION("Move -", TRUE).
shoulder12:DOACTION("Move +", TRUE).

WAIT shoulderDelay.

shoulder1:DOACTION("Move +", FALSE).
shoulder3:DOACTION("Move -", FALSE).
shoulder5:DOACTION("Move +", FALSE).
shoulder7:DOACTION("Move -", FALSE).
shoulder9:DOACTION("Move +", FALSE).
shoulder11:DOACTION("Move -", FALSE).

shoulder2:DOACTION("Move -", FALSE).
shoulder4:DOACTION("Move +", FALSE).
shoulder6:DOACTION("Move -", FALSE).
shoulder8:DOACTION("Move +", FALSE).
shoulder10:DOACTION("Move -", FALSE).
shoulder12:DOACTION("Move +", FALSE).