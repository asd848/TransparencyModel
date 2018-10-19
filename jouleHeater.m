function [finalModel, solution] = jouleHeater(sizeSquare,dcVoltage)
height= sizeSquare;
width = sizeSquare;


model = createpde(); 

gd = (1:10)';
ns = [""];
sf = "";
for i = 1:width
    for j = 1:height
        gd(1:end, end+1) = [3;4;i-1;i;i;i-1;j;j;j-1;j-1;];
        ns(end + 1) = "R" + num2str(i) + num2str(j);
        if sf == ""
            sf = ns(end);
        else
            sf = sf + " + " + ns(end); 
        end
    end
end
gd = gd(1:end, 2:end);
ns = ns(2:end);

g = decsg(gd, sf, ns);
geometryFromEdges(model,g);
% Applying boundary conditions to edges
for i = 1:height
    %Left and Right Edges
   applyBoundaryCondition(model,'neumann','Edge',i,'q',0,'g',0)
   applyBoundaryCondition(model,'neumann','Edge',height*width*2-i,'q',0,'g',0)
end
for i = 1:width
    %Top and Bottom Edges (where we set our voltage)
   applyBoundaryCondition(model,'dirichlet','Edge',(height*width)-i+1,'r',-dcVoltage,'h',1) 
   applyBoundaryCondition(model,'dirichlet','Edge',(height*width)*2-sizeSquare-i+1,'r',dcVoltage,'h',1) 
end

for i = 1:width*height
   specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0,'face',i) 
end


figure(4);
pdegplot(model, 'FaceLabels', 'on')

generateMesh(model);
solution = solvepde(model); % for stationary problems

u = solution.NodalSolution;
figure(2);
pdeplot(model,'XYData',u,'Mesh','on')
xlabel('x')
ylabel('y')

finalModel = model;
end
