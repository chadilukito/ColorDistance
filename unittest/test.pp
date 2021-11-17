unit test;
{$modeswitch UnicodeStrings}
{$H+}

interface

uses TestFramework, BGRABitmapTypes, colordistance;

type
  cColorDistanceTest = class(TTestCase)
    private
      procedure printDeltaE2000(no: Byte; expected: Double; col1, col2: Array of Double);
      procedure printDeltaE2000_1(no: Byte; expected: Double; col1: TBGRAPixel; col2: String);

    published
      procedure Test_DeltaE76;
      procedure Test_DeltaE94;
      procedure Test_DeltaE2000;
      procedure Test_DeltaE2000_1;
  end;


procedure RegisterTests;

implementation

uses sysutils, typinfo, math, bgracolorex;

procedure RegisterTests;
begin
  TestFramework.RegisterTest('ColorDistance Test Suite', cColorDistanceTest.Suite);
end;

procedure cColorDistanceTest.Test_DeltaE76;
  var
     cd: cColorDistance;
     col1, col2: TColorEx;

  begin
    // http://colormine.org/delta-e-calculator

    col1.AsLabA := TLabA.New(36, 60, 41, 0);
    col2.AsLabA := TLabA.New(55, 66, 77, 0);
    cd := cColorDistance.Create(col1, col2);
    CheckEquals(RoundTo(41.1461, -4), RoundTo(cd.getDeltaE76(), -4), 'Failed - DeltaE76 1');
  end;

procedure cColorDistanceTest.Test_DeltaE94;
  var
     cd: cColorDistance;
     col1, col2: TColorEx;

  begin
    // http://colormine.org/delta-e-calculator/cie94

    col1.AsLabA := TLabA.New(36, 60, 41, 0);
    col2.AsLabA := TLabA.New(55, 66, 77, 0);
    cd := cColorDistance.Create(col1, col2);
    CheckEquals(RoundTo(22.8493, -4), RoundTo(cd.getDeltaE94(), -4), 'Failed - DeltaE94 1');
  end;

procedure cColorDistanceTest.printDeltaE2000(no: Byte; expected: Double; col1, col2: Array of Double);
  var
     cd: cColorDistance;
     collab1, collab2: TColorEx;

  begin
    collab1.AsLabA := TLabA.New(col1[0], col1[1], col1[2], 0);
    collab2.AsLabA := TLabA.New(col2[0], col2[1], col2[2], 0);
    cd := cColorDistance.Create(collab1, collab2);
    CheckEquals(RoundTo(expected, -4), RoundTo(cd.getDeltaE2000(), -4), 'Failed - DeltaE2000 '+IntToStr(no));
  end;

procedure cColorDistanceTest.Test_DeltaE2000;
  begin
    // Tests taken from Table 1: "CIEDE2000 total color difference test data" of
    // "The CIEDE2000 Color-Difference Formula: Implementation Notes,
    // Supplementary Test Data, and Mathematical Observations" by Gaurav Sharma,
    // Wencheng Wu and Edul N. Dalal.
    //
    // http://www.ece.rochester.edu/~gsharma/papers/CIEDE2000CRNAFeb05.pdf

    printDeltaE2000(1, 0.0, [0,0,0], [0,0,0]);
    printDeltaE2000(2, 0.0, [99.5, 0.005, -0.010], [99.5, 0.005, -0.010]);
    printDeltaE2000(3, 100.0, [100.0, 0.005, -0.010], [0.0, 0.0, 0.0]);
    printDeltaE2000(4, 2.0425, [50.0000, 2.6772, -79.7751], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(5, 2.8615, [50.0000, 3.1571, -77.2803], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(6, 3.4412, [50.0000, 2.8361, -74.0200], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(7, 1.0000, [50.0000, -1.3802, -84.2814], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(8, 1.0000, [50.0000, -1.1848, -84.8006], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(9, 1.0000, [50.0000, -0.9009, -85.5211], [50.0000, 0.0000, -82.7485]);
    printDeltaE2000(10, 2.3669, [50.0000, 0.0000, 0.0000], [50.0000, -1.0000, 2.0000]);
    printDeltaE2000(11, 2.3669, [50.0000, -1.0000, 2.0000], [50.0000, 0.0000, 0.0000]);
    printDeltaE2000(12, 7.1792, [50.0000, 2.4900, -0.0010], [50.0000, -2.4900, 0.0009]);
    printDeltaE2000(13, 7.1792, [50.0000, 2.4900, -0.0010], [50.0000, -2.4900, 0.0010]);
    printDeltaE2000(14, 7.2195, [50.0000, 2.4900, -0.0010], [50.0000, -2.4900, 0.0011]);
    printDeltaE2000(15, 7.2195, [50.0000, 2.4900, -0.0010], [50.0000, -2.4900, 0.0012]);
    printDeltaE2000(16, 4.8045, [50.0000, -0.0010, 2.4900], [50.0000, 0.0009, -2.4900]);
    printDeltaE2000(17, 4.7461, [50.0000, -0.0010, 2.4900], [50.0000, 0.0011, -2.4900]);
    printDeltaE2000(18, 4.3065, [50.0000, 2.5000, 0.0000], [50.0000, 0.0000, -2.5000]);
    printDeltaE2000(19, 27.1492, [50.0000, 2.5000, 0.0000], [73.0000, 25.0000, -18.0000]);
    printDeltaE2000(20, 22.8977, [50.0000, 2.5000, 0.0000], [61.0000, -5.0000, 29.0000]);
    printDeltaE2000(21, 31.9030, [50.0000, 2.5000, 0.0000], [56.0000, -27.0000, -3.0000]);
    printDeltaE2000(22, 19.4535, [50.0000, 2.5000, 0.0000], [58.0000, 24.0000, 15.0000]);
    printDeltaE2000(23, 1.0000, [50.0000, 2.5000, 0.0000], [50.0000, 3.1736, 0.5854]);
    printDeltaE2000(24, 1.0000, [50.0000, 2.5000, 0.0000], [50.0000, 3.2972, 0.0000]);
    printDeltaE2000(25, 1.0000, [50.0000, 2.5000, 0.0000], [50.0000, 1.8634, 0.5757]);
    printDeltaE2000(26, 1.0000, [50.0000, 2.5000, 0.0000], [50.0000, 3.2592, 0.3350]);
    printDeltaE2000(27, 1.2644, [60.2574, -34.0099, 36.2677], [60.4626, -34.1751, 39.4387]);
    printDeltaE2000(28, 1.2630, [63.0109, -31.0961, -5.8663], [62.8187, -29.7946, -4.0864]);
    printDeltaE2000(29, 1.8731, [61.2901, 3.7196, -5.3901], [61.4292, 2.2480, -4.9620]);
    printDeltaE2000(30, 1.8645, [35.0831, -44.1164, 3.7933], [35.0232, -40.0716, 1.5901]);
    printDeltaE2000(31, 2.0373, [22.7233, 20.0904, -46.6940], [23.0331, 14.9730, -42.5619]);
    printDeltaE2000(32, 1.4146, [36.4612, 47.8580, 18.3852], [36.2715, 50.5065, 21.2231]);
    printDeltaE2000(33, 1.4441, [90.8027, -2.0831, 1.4410], [91.1528, -1.6435, 0.0447]);
    printDeltaE2000(34, 1.5381, [90.9257, -0.5406, -0.9208], [88.6381, -0.8985, -0.7239]);
    printDeltaE2000(35, 0.6377, [6.7747, -0.2908, -2.4247], [5.8714, -0.0985, -2.2286]);
    printDeltaE2000(36, 0.9082, [2.0776, 0.0795, -1.1350], [0.9033, -0.0636, -0.5514]);
  end;

procedure cColorDistanceTest.printDeltaE2000_1(no: Byte; expected: Double; col1: TBGRAPixel; col2: String);
  var
     cd: cColorDistance;
     collab1, collab2: TColorEx;

  begin
    collab1.AsBGRAPixel := col1;
    collab2.AsHex := col2;
    cd := cColorDistance.Create(collab1, collab2);
    CheckEquals(RoundTo(expected, -4), RoundTo(cd.getDeltaE2000(), -4), 'Failed - DeltaE2000_1 '+IntToStr(no));
  end;

procedure cColorDistanceTest.Test_DeltaE2000_1;
  begin
    // BGRA(107, 142, 35) = #6b8e23 = CSSOliveDrab
    printDeltaE2000_1(1, 32.2455, BGRA(107, 142, 35), 'ECF0E8FF');
    printDeltaE2000_1(2, 7.2178, BGRA(107, 142, 35), '7F9C4EFF');
    printDeltaE2000_1(3, 19.6571, BGRA(107, 142, 35), 'AEBF96FF');
    printDeltaE2000_1(4, 24.9612, BGRA(107, 142, 35), 'C7D2B7FF');
    printDeltaE2000_1(5, 33.0829, BGRA(107, 142, 35), 'F1F4EEFF');
    printDeltaE2000_1(6, 18.1697, BGRA(107, 142, 35), 'A8BA8DFF');
    printDeltaE2000_1(7, 7.4103, BGRA(107, 142, 35), '809D4FFF');
    printDeltaE2000_1(8, 25.297, BGRA(107, 142, 35), 'C9D3B9FF');
    printDeltaE2000_1(9, 9.1681, BGRA(107, 142, 35), '86A159FF');
    printDeltaE2000_1(10, 35.064, BGRA(107, 142, 35), 'FDFDFCFF');
    printDeltaE2000_1(11, 31.8678, BGRA(107, 142, 35), 'EBEEE5FF');
    printDeltaE2000_1(12, 5.9837, BGRA(107, 142, 35), '7C9947FF');
    printDeltaE2000_1(13, 25.5383, BGRA(107, 142, 35), 'CAD5BBFF');
    printDeltaE2000_1(14, 34.3406, BGRA(107, 142, 35), 'F9FAF7FF');
    printDeltaE2000_1(15, 33.1134, BGRA(107, 142, 35), 'F2F4EEFF');
    printDeltaE2000_1(16, 31.9483, BGRA(107, 142, 35), 'EBEFE6FF');
    printDeltaE2000_1(17, 12.5001, BGRA(107, 142, 35), '91A96CFF');
    printDeltaE2000_1(18, 17.1557, BGRA(107, 142, 35), 'A4B787FF');
    printDeltaE2000_1(19, 34.5294, BGRA(107, 142, 35), 'F9FAF8FF');
    printDeltaE2000_1(20, 18.013, BGRA(107, 142, 35), 'A7B98CFF');
    printDeltaE2000_1(21, 18.8112, BGRA(107, 142, 35), 'ABBD91FF');
    printDeltaE2000_1(22, 31.1296, BGRA(107, 142, 35), 'E7EBE0FF');
    printDeltaE2000_1(23, 17.9963, BGRA(107, 142, 35), 'A8BA8CFF');
    printDeltaE2000_1(24, 33.9129, BGRA(107, 142, 35), 'F6F8F4FF');
    printDeltaE2000_1(25, 25.1646, BGRA(107, 142, 35), 'C8D2B8FF');
    printDeltaE2000_1(26, 33.702, BGRA(107, 142, 35), 'F4F6F2FF');
    printDeltaE2000_1(27, 35.1656, BGRA(107, 142, 35), 'FEFEFDFF');
    printDeltaE2000_1(28, 32.7878, BGRA(107, 142, 35), 'F0F3ECFF');
    printDeltaE2000_1(29, 11.9817, BGRA(107, 142, 35), '90A869FF');
    printDeltaE2000_1(30, 27.2801, BGRA(107, 142, 35), 'D3DBC6FF');
  end;

end.