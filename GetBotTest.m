function [Bots, Goals, Leader_Exists] = GetBotTest(test_nr)

switch test_nr
    case 1
        Leader_Exists = false;
        Bots = [3 0 0 0 0;
                -3 0 0 0 0];
        Goals = [-3 6;
                 3 6];
             
    case 2
        Leader_Exists = false;
        Bots = [3 0 0 0 0;
                -3 0 0 0 0];
        Goals = [0.2 0;
                 -0.2 0];
    
    case 3
        Leader_Exists = false;
        Bots = [3 0 0 0 0;
                0 3 0 0 0;
               -3 0 0 0 0;
                0 -3 0 0 0];
        Goals = [   -3 0;
                    0 -3;
                    3 0;
                    0 3];
        
                
    case 4
        Leader_Exists = false;
        Bots = [1 1 0 0 0;
                2 1 0 0 0;
                3 1 0 0 0;
                4 1 0 0 0;
                5 1 0 0 0];
        Goals = [   4 4;
                    2 4;
                    6 4;
                    4 2;
                    4 6];
    case 5
        Leader_Exists = false;
        Bots = [2  0 0 0 0;
                -2 0 0 0 0;
                0  2 0 0 0;
                0 -2 0 0 0];
        Goals = [   -0.2 0;
                    0.2 0;
                    0 -0.2;
                    0 0.2;];
    case 6
        Leader_Exists = false;
        Bots = [2  0 0 0 0;
                -2 0 0 0 0;
                0  2 0 0 0;
                0 -2 0 0 0;
                2/sqrt(2) 2/sqrt(2) 0 0 0;
                -2/sqrt(2) -2/sqrt(2) 0 0 0;
                -2/sqrt(2) 2/sqrt(2) 0 0 0;
                2/sqrt(2) -2/sqrt(2) 0 0 0];
        Goals = [-2 0;
                2 0;
                0 -2;
                0 2;
                -2/sqrt(2) -2/sqrt(2);
                2/sqrt(2) 2/sqrt(2);
                2/sqrt(2) -2/sqrt(2);
                -2/sqrt(2) 2/sqrt(2)];
            
    case 7
        Leader_Exists = true;
        Bots = 0.8*[0 0 0 0 0;
                1 0 0 0 0;
                2 0 0 0 0;
                3 0 0 0 0;
                4 0 0 0 0];
        Goals = 0.8*[0  0;
                -1  1;
                -1 -1;
                -2 -2;
                -2 2];
        
    case 8
        Leader_Exists = true;
        Bots = [-5 0 0 0 0;
                -3 -4 0 0 0;
                -2 -4 0 0 0;
                -1 -4 0 0 0;
                0 -4 0 0 0;
                1 -4 0 0 0;
                2 -4 0 0 0;
                3 -4 0 0 0;
                4 -4 0 0 0];
        Goals = 0.1*[0  0;
                -1  1;
                -1 -1;
                -2 -2;
                -2 2;
                 1 1;
                 1 -1;
                 2 -2;
                 2 2];
     
    case 9
        Leader_Exists = true;
        Bots = [-5 0 0 0 0;
                -3 -4 0 0 0;
                -2 -4 0 0 0;
                -1 -4 0 0 0;
                0 -4 0 0 0];
        Goals = 0.3*[0  0;
                -1  1;
                -1 -1;
                1 -1;
                1 1];
            
    case 10
        Leader_Exists = false;
        Bots = [0 0 0 0 0];
        Goals = [3 0];
        
    case 11
        Leader_Exists = true;
        Bots = [0 0 0 0 0;
                -3 1.5 1 1 0;
                -4 -1 -1 0.5 0;
                -2 0 1 -1 0;
                -2.7 -1.5 0.7 1 0];
        Goals = [0  0;
                -1  1;
                -0.5 0.5;
                -0.5 -0.5;
                -1 -1];
end