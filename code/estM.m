function m = estM(phi,d)
    % m = d(2.tan(thetaR) - tan(thetaM)) / (tan(thetaM) - tan(thetaR))
    m = d * (2*tan(phi(3)) - tan(phi(2)) / (tan(phi(2)) - tan(phi(3))));

end