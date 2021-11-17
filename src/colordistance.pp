{
    MIT License

    Copyright (c) 2021 Christian Hadi

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
}

unit colordistance;
{$H+}
interface

uses bgracolorex;

type
  cColorDistance = class
    private
      _Color1, _Color2: TColorEx;

    public
      property Color1: TColorEx read _Color1 write _Color1;
      property Color2: TColorEx read _Color2 write _Color2;

      constructor create(const aColor1, aColor2: TColorEx);

      function getDeltaE76(): Double;
      function getDeltaE94(): Double;
      function getDeltaE2000(): Double;
  end;

implementation

uses math, BGRABitmapTypes;

constructor cColorDistance.create(const aColor1, aColor2: TColorEx);
  begin
    _Color1 := aColor1;
    _Color2 := aColor2;
  end;

function cColorDistance.getDeltaE76(): Double;
  var
     lab1, lab2: TLabA;

  begin
    lab1 := _Color1.ToLabA;
    lab2 := _Color2.ToLabA;

    result := sqrt(power((lab2.L - lab1.L), 2) + power((lab2.a - lab1.a), 2) + power((lab2.b - lab1.b), 2));
  end;

function cColorDistance.getDeltaE94(): Double;
  var
     lab1, lab2: TLabA;
     k_L, k_C, k_H: Double;
     SL, SC, SH: Double;
     K1, K2: Double;
     delta_L, delta_C, delta_H: Double;
     C1, C2: Double;
     deltaa, deltab: Double;

  begin
    lab1 := _Color1.ToLabA;
    lab2 := _Color2.ToLabA;

    k_L := 1.0;
    k_C := 1.0;
    k_H := 1.0;
    K1 := 0.045;
    K2 := 0.015;

    delta_L := lab1.L - lab2.L;
    
    C1 := sqrt(lab1.a * lab1.a + lab1.b * lab1.b);
    C2 := sqrt(lab2.a * lab2.a + lab2.b * lab2.b);
    delta_C := C1 - C2;
    deltaa := lab1.a - lab2.a;
    deltab := lab2.b - lab1.b;
    delta_H := sqrt(power(deltaa, 2) + power(deltab, 2) - power(delta_C, 2));

    SL := 1;
    SC := 1 + K1 * C1;
    SH := 1 + K2 * C1;

    delta_L := delta_L / (SL * k_L);
    delta_C := delta_C / (SC * k_C);
    delta_H := delta_H / (SH * k_H);

    result := sqrt(delta_L * delta_L + delta_C * delta_C + delta_H * delta_H);
  end;

function cColorDistance.getDeltaE2000(): Double;
  var
     lch1, lch2: TLChA;
     lab1, lab2: TLabA;
     k_L, k_C, k_H: Double;
     avg_L, delta_L, avg_C, avg_C_c, delta_C_c, avg_H_c, delta_H_c: Double;
     a1_c, a2_c, h1_c, h2_c, c1_c, c2_c: Double;
     T, SL, SC, SH: Double;
     delta_Theta, RT: Double;
     c25pow7: Double;
     deg180, deg360: Double;

  begin
    lch1 := _Color1.ToLChA;
    lch2 := _Color2.ToLChA;
    lab1 := _Color1.ToLabA;
    lab2 := _Color2.ToLabA;

    c25pow7 := 6103515625.0; // 6103515625 = 25^7
    deg180 := 180.0;
    deg360 := 360.0;

    k_L := 1.0;
    k_C := 1.0;
    k_H := 1.0;

    avg_L := (lch1.L + lch2.L) * 0.5;
    delta_L := lch2.L - lch1.L;
    avg_C := (lch1.C + lch2.C) * 0.5;
    avg_C := power(avg_C, 7.0);

    a1_c := lab1.a + lab1.a * 0.5 * (1 - sqrt(avg_C / (avg_C + c25pow7)));
    a2_c := lab2.a + lab2.a * 0.5 * (1 - sqrt(avg_C / (avg_C + c25pow7)));
    c1_c := sqrt(a1_c * a1_c + lab1.b * lab1.b);
    c2_c := sqrt(a2_c * a2_c + lab2.b * lab2.b);

    avg_C_c := (c1_c + c2_c) * 0.5;
    delta_C_c := c2_c - c1_c;

    if ((lab1.b = 0.0) and (a1_c = 0.0)) then
      h1_c := 0.0
    else
    begin
      h1_c := RadToDeg(arctan2(lab1.b, a1_c));

      if (h1_c < 0.0) then h1_c := h1_c + 360.0;
    end;

    if ((lab2.b = 0.0) and (a2_c = 0.0)) then
      h2_c := 0.0
    else
    begin
      h2_c := RadToDeg(arctan2(lab2.b, a2_c));

      if (h2_c < 0.0) then h2_c := h2_c + 360.0;
    end;

    avg_H_c := h1_c + h2_c;
    if ((c1_c <> 0.0) and (c2_c <> 0.0)) then
      begin
        if (CompareValue(RoundTo(abs(h1_c - h2_c), -4), RoundTo(deg180, -4)) = GreaterThanValue) then
          begin
            if (CompareValue(RoundTo(avg_H_c, -4), RoundTo(deg360, -4)) = LessThanValue) then
              avg_H_c := avg_H_c + 360.0
            else
              avg_H_c := avg_H_c - 360.0;
          end;

        avg_H_c := avg_H_c * 0.5;
      end;

    if ((c1_c <> 0.0) and (c2_c <> 0.0)) then
      begin
        delta_H_c := h2_c - h1_c;
        if (CompareValue(RoundTo(abs(delta_H_c), -4), RoundTo(deg180, -4)) = GreaterThanValue) then
          begin
            if (h2_c <= h1_c) then
              delta_H_c := delta_H_c + 360.0
            else
              delta_H_c := delta_H_c - 360.0;
          end;
      end else
      delta_H_c := 0.0;

    delta_H_c := sqrt(c1_c * c2_c) * sin(DegToRad(delta_H_c) / 2) * 2.0;

    T := 1.0 -
         0.17 * cos(DegToRad(avg_H_c - 30.0)) +
         0.24 * cos(DegToRad(avg_H_c * 2.0)) +
         0.32 * cos(DegToRad(avg_H_c * 3.0 + 6.0)) -
         0.20 * cos(DegToRad(avg_H_c * 4.0 - 63.0));

    SL := avg_L - 50.0;
    SL := SL * SL;
    SL := SL * 0.015 / sqrt(SL + 20.0) + 1.0;
    SC := avg_C_c * 0.045 + 1.0;
    SH := avg_C_c * T * 0.015 + 1.0;

    delta_Theta := (avg_H_c - 275.0) / 25.0;
    delta_Theta := exp(delta_Theta * -delta_Theta) * 60.0;
    RT := power(avg_C_c, 7.0);
    RT := sqrt(RT / (RT + c25pow7)) * sin(DegToRad(delta_Theta)) * -2.0;
        
    delta_L := delta_L / (SL * k_L);
    delta_C_c := delta_C_c / (SC * k_C);
    delta_H_c := delta_H_c / (SH * k_H);

    result := sqrt(delta_L * delta_L + delta_C_c * delta_C_c + delta_H_c * delta_H_c + RT * delta_C_c * delta_H_c);
  end;

end.