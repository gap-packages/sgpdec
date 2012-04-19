#############################################################################
##
## stack.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2010 University of Hertfordshire, Hatfield, UK
##
## Simple stack implementation.
##

InstallGlobalFunction(Stack,
function()
  return Objectify(StackType, rec(l:=[],pointer:=0));
end
);

InstallMethod(Store,"push for a stack",[IsStack and IsStackRep,IsObject],
function(stack, element)
  stack!.pointer := stack!.pointer + 1;
  stack!.l[stack!.pointer] := element;
end
);

InstallMethod(Retrieve,"pop for a stack", [IsStack and IsStackRep],
function(stack)
local result, pointer;
  #for quicker access, avoiding revord member search
  pointer := stack!.pointer;

  result := stack!.l[pointer];
  Remove(stack!.l,pointer);
  stack!.pointer := pointer - 1;
  return result;
end
);


InstallMethod(Peek,"peeking to top element of a stack", [IsStack and IsStackRep],
function(stack)
local result;  
  return stack!.l[stack!.pointer];
end
);


#Reimplemented methods
InstallMethod(IsEmpty, "for stacks", [IsStack and IsStackRep],
function(stack) 
        return stack!.pointer = 0;
end);

InstallMethod( Size,"for stack", [IsStack and IsStackRep],
function( stack )
  return Size(stack!.l);
end
);


InstallMethod( ViewObj,"for stack",[IsStack and IsStackRep],
function( stack )
  Print("Stack: ", stack!.l, "<-");
end
);

InstallMethod( Display,"for stack", [IsStack and IsStackRep],
function( stack )
  ViewObj(stack);
  Print("\n");
end
);
