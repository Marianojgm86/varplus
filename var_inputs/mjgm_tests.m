Inv1 = inv(X'*X);

% Form -> A/B = A^(-1)*B
A = X'*X;
B = eye(m);
testAB = A\B;
testAB2 = inv(A)*B;
test3 = inv(A);

Inv2 = (X'*X)/eye(m);
Inv3 = (X'*X)\eye(m);