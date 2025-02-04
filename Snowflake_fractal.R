
#съзваваме платно, на което да работим
emptyCanvas <- function(xlim, ylim, bg="gray20") {
  par(mar=rep(1,4), bg=bg)
  plot(1, 
       type="n", 
       bty="n",
       xlab="", ylab="", 
       xaxt="n", yaxt="n",
       xlim=xlim, ylim=ylim)
}

#създаване на линия, която има 2 точки със съответните координати
drawLine <- function(line, col="white", lwd=1) {
  segments(x0=line[1], 
           y0=line[2], 
           x1=line[3], 
           y1=line[4], 
           col=col,
           lwd=lwd)
}

# ако искаме да нарисуваме обект, то ще добавим отделните линии в масив и ще го начертаем
drawObject <- function(object, col="white", lwd=1) {
  invisible(apply(object, 1, drawLine, col=col, lwd=lwd))
}

#ф-я, която чертае нови линии спрямо стари
# angle - ъгъл спрямо старата линия
# reduce - размер спрямо старата линия

newLine <- function(line, angle, reduce=1) {
  
  x0 <- line[1]
  y0 <- line[2]
  x1 <- line[3]
  y1 <- line[4]
  
  dx <- unname(x1-x0)                      # сменяне на х посоката
  dy <- unname(y1-y0)                      # сменяне на у посоката
  l <- sqrt(dx^2 + dy^2)                   # променяне дължината на линията
  
  theta <- atan(dy/dx) * 180 / pi          # ъгъл между новата и старата
  rad <- (angle+theta) * pi / 180          # в радиани
  
  coeff <- sign(theta)*sign(dy)            # coefficient of direction
  if(coeff == 0) coeff <- -1
  
  x2 <- x0 + coeff*l*cos(rad)*reduce + dx  # новата позиция на х
  y2 <- y0 + coeff*l*sin(rad)*reduce + dy  # новата позиция на у
  return(c(x1,y1,x2,y2))
  
}

#ф-я която да променя новата линия чрез някакво правило/ф-я ifun
iterate <- function(object, ifun, ...) {
  linesList <- vector("list",0)
  for(i in 1:nrow(object)) {
    old_line <- matrix(object[i,], nrow=1)
    new_line <- ifun(old_line, ...)
    linesList[[length(linesList)+1]] <- new_line
  }
  new_object <- do.call(rbind, linesList)
  return(new_object)
}

#създаване на ф-ята която да променя новите линии
koch <- function(line0) {
  
  # new triangle (starting at right)
  line1 <- newLine(line0, angle=180, reduce=1/3)
  line2 <- newLine(line1, angle=-60, reduce=1)
  line3 <- newLine(line2, angle=120, reduce=1)
  line4 <- newLine(line3, angle=-60, reduce=1)
  
  # reorder lines (to start at left)
  line1 <- line1[c(3,4,1,2)]
  line2 <- line2[c(3,4,1,2)]
  line3 <- line3[c(3,4,1,2)]
  line4 <- line4[c(3,4,1,2)]
  
  # store in matrix and return
  mat <- matrix(c(line4,line3,line2,line1), byrow=T, ncol=4)
  return(mat)
  
}

#чертане на снежинката
#за да стане трябва да започнем да итерираме от начална фигура триъгълник
# А, Б, Ц са ни точките на триъгълника
A <- c(0,1e-9)
B <- c(3,5)
C <- c(6,0)
fractal <- matrix(c(A,B,B,C,C,A), nrow=3, byrow=T)
for(i in 1:6) fractal <- iterate(fractal, ifun=koch)
emptyCanvas(xlim=c(-2,8), ylim=c(-2,5))
drawObject(fractal)