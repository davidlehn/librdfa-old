// Copyright 2008 Digital Bazaar, Inc.
//
// This file is part of librdfa.
//
// librdfa is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// librdfa is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with librdfa. If not, see <http://www.gnu.org/licenses/>.
//
// @author Manu Sporny
%module rdfa
%{
#include "stdlib.h"
#include "RdfaParser.h"
#include "rdfa_utils.h"
#include "rdfa.h"

RdfaParser* gRdfaParser = NULL;
void process_triple(rdftriple* triple, void* callback_data);
size_t fill_buffer(char* buffer, size_t buffer_length, void* callback_data);

%}

%constant int RDF_TYPE_NAMESPACE_PREFIX = RDF_TYPE_NAMESPACE_PREFIX;
%constant int RDF_TYPE_IRI = RDF_TYPE_IRI;
%constant int RDF_TYPE_PLAIN_LITERAL = RDF_TYPE_PLAIN_LITERAL;
%constant int RDF_TYPE_XML_LITERAL = RDF_TYPE_XML_LITERAL;
%constant int RDF_TYPE_TYPED_LITERAL = RDF_TYPE_TYPED_LITERAL;

// Grab a Python function object as a Python object.
#ifdef SWIGPYTHON
%typemap(in) PyObject *pyfunc {
  if (!PyCallable_Check($input)) {
      PyErr_SetString(PyExc_TypeError, "Need a callable object!");
      return NULL;
  }
  $1 = $input;
}

%include RdfaParser.h

%{
void process_triple(rdftriple* triple, void* callback_data)
{
   PyGILState_STATE state = PyGILState_Ensure();
   PyObject* func;
   PyObject* data = (PyObject*)gRdfaParser->mTripleHandlerData;
   PyObject* arglist;
   PyObject* pyresult;

   // call the Python function to get the data for the buffer
   func = (PyObject*)gRdfaParser->mTripleHandlerCallback;
   arglist = Py_BuildValue((char*)"(Osssiss)", data, triple->subject, 
      triple->predicate, triple->object, triple->object_type, 
      (char*)triple->datatype, triple->language);

   PyEval_CallObject(func, arglist);
   Py_DECREF(arglist);

   rdfa_free_triple(triple);

   PyGILState_Release(state);
}

size_t fill_buffer(char* buffer, size_t buffer_length, void* callback_data)
{
   PyGILState_STATE state = PyGILState_Ensure();

   size_t rval = 0;
   PyObject* func;
   PyObject* dataFile = (PyObject*)gRdfaParser->mBufferFillerData;
   PyObject* arglist;
   PyObject* pyresult;

   // call the Python function to get the data for the buffer
   func = (PyObject*)gRdfaParser->mBufferFillerCallback;
   arglist = Py_BuildValue((char*)"(Oi)", dataFile, buffer_length);

   pyresult = PyEval_CallObject(func, arglist);
   Py_DECREF(arglist);

   // if we got a result, make sure that it is properly formatted and of the 
   // correct type.
   if(pyresult != NULL)
   {
      if(PyString_Check(pyresult))
      {
         // set the buffer if everything checks out
         char* sdata = PyString_AsString(pyresult);
         rval = PyString_Size(pyresult);
         strcpy(buffer, sdata);
      }
      else
      {
         PyErr_SetString(PyExc_TypeError, 
            "Buffer filler callback return type must be a string!");
      }
   }
   else
   {
      PyErr_SetString(PyExc_TypeError, 
            "Call to buffer filler failed from librdfa!");
   }
   Py_XDECREF(pyresult);

   PyGILState_Release(state);

   return rval;
}
%}

// Attach a new method to our plot widget for adding Python functions
%extend RdfaParser {
   // Set a Python function object as a callback function
   // Note : PyObject *pyfunc is remapped with a typempap

   /**
    * Sets the triple handler callback for when triples are generated
    * by librdfa and need to be passed up to the application for
    * processing.
    */
   void setTripleHandler(PyObject *pyfunc, PyObject* data) 
   {
      PyGILState_STATE state = PyGILState_Ensure();
      gRdfaParser = self;
      gRdfaParser->mTripleHandlerCallback = pyfunc;
      gRdfaParser->mTripleHandlerData = data;
      rdfa_set_triple_handler(gRdfaParser->mBaseContext, process_triple);
      Py_INCREF(pyfunc);
      Py_INCREF(data);
      PyGILState_Release(state);
   }

   /**
    * Sets the buffer filler callback for when more data is needed by
    * the XML parser when generating triples. Since librdfa is
    * stream-based, these reads usually happen in 4KB chunks.
    */
   void setBufferHandler(PyObject *pyfunc, PyObject* data) 
   {
      PyGILState_STATE state = PyGILState_Ensure();
      gRdfaParser = self;
      gRdfaParser->mBufferFillerCallback = pyfunc;
      gRdfaParser->mBufferFillerData = data;
      rdfa_set_buffer_filler(gRdfaParser->mBaseContext, &fill_buffer);
      Py_INCREF(pyfunc);
      Py_INCREF(data);
      PyGILState_Release(state);
   }
}
#endif
